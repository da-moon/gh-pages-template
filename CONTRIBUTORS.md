# Contributors Rules

This guide defines generic React best practices you can drop into any project.
It mirrors the style of our root guide: short rule IDs, a rules table, and
detailed "don't/ do" examples. Use rule IDs in PRs, TODOs, and reviews to keep
context small.

## Rules Table

| Rule ID | Rule Summary                                                              |
| ------- | ------------------------------------------------------------------------- |
| R1      | Prefer domain models (interfaces/classes) over loose records/maps         |
| R2      | Replace switch/case with typed maps for domain metadata                   |
| R3      | Keep UI copy out of components; use constants/static content              |
| R4      | Split large components; one responsibility per file                       |
| R5      | Move behavior to hooks/utils; avoid duplicated side effects               |
| R6      | Use shared style tokens; avoid ad-hoc class chains                        |
| R7      | Avoid dynamic class string generation; use explicit maps/enums            |
| R8      | Presentational vs. container: components render, logic elsewhere          |
| R9      | Accessibility: ARIA roles, keyboard support, and labeling                 |
| R10     | Testability: pure helpers, no side effects in render, DI where needed     |
| R11     | Externalize long docs/snippets; import markdown/raw content               |
| R12     | Prop design: defaults, minimal surface, prefer objects over boolean soups |
| R13     | State: keep minimal and derived; memoize judiciously                      |

---

## 1. Domain Models Over Loose Shapes (R1)

Model configuration and content with explicit interfaces (and enums). Use
classes only when you need domain behavior (methods/invariants). Use typed
registries (Record<Enum, Model>) instead of stringly-typed maps.

#### ❌ Loose shapes and untyped maps

```ts
const CODE_BLOCKS = {
  yaml: { title: "YAML", language: "yml", icon: GitBranch },
};
```

#### ✅ Interface + factory + typed registry

```ts
type Language = "bash" | "yaml" | "dockerfile" | "markdown";

interface CodeBlockSpec {
  id: string;
  title: string;
  language: Language;
  icon: React.ElementType;
  collapsible?: boolean;
  defaultCollapsed?: boolean;
  maxLines?: number;
}

const createCodeBlockSpec = (s: CodeBlockSpec): CodeBlockSpec => s;

const CODE_BLOCKS: Record<string, CodeBlockSpec> = {
  "gitlab-ci": createCodeBlockSpec({
    id: "gitlab-ci",
    title: "GitLab CI",
    language: "yaml",
    icon: GitBranch,
    collapsible: true,
  }),
};
```

#### ✅ Enum + discriminated unions for variants

```ts
type InstructionType = "command" | "config" | "file" | "note";

interface InstructionBase {
  type: InstructionType;
  title: string;
  content: string;
  description?: string;
}

type Instruction =
  | (InstructionBase & { type: "command"; language: "bash" })
  | (InstructionBase & { type: "config"; language: "yaml" })
  | (InstructionBase & { type: "file"; language: "text" })
  | (InstructionBase & { type: "note"; language?: "markdown" });
```

#### ✅ Class when behavior/invariants matter

```ts
class CodeBlockSpecModel {
  readonly id: string;
  readonly title: string;
  readonly language: Language;
  readonly icon: React.ElementType;
  readonly collapsible: boolean;
  readonly defaultCollapsed: boolean;
  readonly maxLines: number;
  constructor(s: CodeBlockSpec) {
    this.id = s.id;
    this.title = s.title.trim();
    this.language = s.language === "yml" ? "yaml" : s.language;
    this.icon = s.icon;
    this.collapsible = s.collapsible ?? true;
    this.defaultCollapsed = s.defaultCollapsed ?? false;
    this.maxLines = s.maxLines ?? 10;
  }
  badgeClass() {
    return this.language === "yaml"
      ? "bg-blue-900/20 text-blue-300"
      : "bg-gray-800/20 text-gray-300";
  }
}
```

When to choose what

- Interface (+ factory/helpers): default for domain data (e.g., code block
  specs, instruction items).
- Typed registry: lookups keyed by enum/ID should be `Record<Enum|ID, Model>`.
- Class: only when you need methods, normalization, or invariants on the model.

This complements R2 (typed maps): maps handle lookup; models define
shape/behavior.

---

## 2. Typed Maps over Switch (R2)

#### ❌ Repetitive switch

```ts
function getIcon(t: "info" | "warn" | "error") {
  switch (t /* ... */) {
  }
}
```

#### ✅ Single source of truth

```ts
type Kind = "info" | "warn" | "error";
const META: Record<Kind, { icon: React.ElementType; label: string }> = {
  info: { icon: Info, label: "Info" },
  warn: { icon: AlertTriangle, label: "Warning" },
  error: { icon: AlertCircle, label: "Error" },
};
```

---

## 3. UI Copy Outside Components (R3)

#### ❌ Inline copy in JSX

```tsx
export default function Header() {
  return <h1>Welcome to the Dashboard</h1>;
}
```

#### ✅ Use constants/static

```tsx
// constants/ui.ts
export const UI = { headings: { main: "Welcome to the Dashboard" } };

// Header.tsx
import { UI } from "../constants/ui";
export default function Header() {
  return <h1>{UI.headings.main}</h1>;
}
```

For long prose, store markdown in `static/...` and import as raw text for
rendering.

---

## 4. One Responsibility Per File (R4)

#### ❌ Monolithic component

```tsx
export default function Dashboard() {
  // header, filters, list, modals, network calls all here
  return <div>...</div>;
}
```

#### ✅ Compose small subcomponents

```tsx
export default function Dashboard() {
  return (
    <>
      <DashboardHeader />
      <Filters />
      <ItemsList />
      <DetailsModal />
    </>
  );
}
```

---

## 5. Behavior in Hooks/Utils (R5)

#### ❌ Duplicated side-effects

```tsx
// Several components copy to clipboard with their own timers
navigator.clipboard.writeText(text);
setTimeout(() => setCopied(false), 2000);
```

#### ✅ Reusable hooks

```tsx
export function useCopyToClipboard() {
  const [copied, setCopied] = React.useState<string | null>(null);
  const copy = React.useCallback((text: string) => {
    navigator.clipboard.writeText(text);
    setCopied(text);
    setTimeout(() => setCopied(null), 2000);
  }, []);
  return { copy, copied };
}
```

---

## 6. Shared Style Tokens (R6)

Define class tokens (or CSS variables) in one place and reuse.

#### ❌ Ad-hoc Tailwind chains everywhere

```tsx
<div className="rounded-lg border p-4 bg-gray-800 text-white" />
```

#### ✅ Centralized tokens

```ts
// constants/styles.ts
export const STYLES = { card: "rounded-lg border p-4 bg-gray-800 text-white" };
```

```tsx
<div className={STYLES.card} />
```

---

## 7. Avoid Dynamic Class Strings (R7)

If using Tailwind or similar purge tools, avoid runtime-built fragments.

#### ❌ Dynamic fragments

```tsx
<div className={`bg-${color}-500 text-${color}-900`} />
```

#### ✅ Explicit map/enums

```ts
const COLOR = {
  blue: "bg-blue-500 text-blue-900",
  red: "bg-red-500 text-red-900",
  gray: "bg-gray-500 text-gray-900",
} as const;
```

```tsx
<div className={COLOR[color] ?? COLOR.gray} />
```

---

## 8. Presentational vs. Container (R8)

#### ❌ Components doing data + UI

````tsx
export default function Users() {
  const [users, setUsers] = useState([]);
  useEffect(() => { fetch('/api/users').then(r => r.json()).then(setUsers); }, []);
  return <UsersTable users={users} />;
}
``;

#### ✅ Separate concerns

```tsx
export function useUsers(){ /* fetch + state here */ }
export function UsersView({ users }:{ users: User[] }){ /* render only */ }
````

---

## 9. Accessibility by Default (R9)

- Tabs: `role="tab"`, `aria-selected`, `aria-controls`; panels:
  `role="tabpanel"`.
- Buttons for interactive elements; add `aria-label` for icon-only buttons.
- Keyboard interactions: Enter/Space for toggles.

---

## 10. Testability (R10)

- Pure helpers in `utils/` (no DOM or global state).
- Avoid side effects in render; effects belong in `useEffect`.
- Inject dependencies (e.g., formatter functions) for easier mocking.

---

## 11. Externalize Long Docs/Snippets (R11)

- Store long markdown, scripts, and sample code in `static/...`.
- Import as raw strings or load at build time; render via a safe markdown/code
  component.

---

## 12. Prop Design (R12)

- Provide sensible defaults; keep prop surfaces small.
- Prefer objects for related options over multiple booleans.

#### ✅ Example

```tsx
type ButtonProps = {
  onClick?: () => void;
  variant?: "primary" | "ghost";
  size?: "sm" | "md" | "lg";
};
export default function Button({
  onClick = () => {},
  variant = "primary",
  size = "md",
}: ButtonProps) {
  // ...
}
```

---

## 13. State & Memoization (R13)

- Keep state minimal; derive where possible.
- Memoize expensive computations with `useMemo` and stable callbacks with
  `useCallback`-only when it matters.

---

## Project Layout Recommendation

```
src/
  components/            # presentational components
  features/              # feature entry components (compose + state)
  constants/             # UI labels, enums, style tokens
  static/                # markdown, scripts, samples
  utils/                 # pure helpers, hooks
```

---

## PR Review Checklist

- [ ] R1: Domain models (interfaces/classes) over loose shapes; typed
      registries
- [ ] R2: Domain metadata via typed maps (no switches)
- [ ] R3: UI copy in constants/static (no long inline strings)
- [ ] R4: Large components split into subcomponents
- [ ] R5: Shared behavior extracted to hooks/utils
- [ ] R6/R7: Classes via tokens or explicit maps (no dynamic fragments)
- [ ] R8: Presentational vs container separation
- [ ] R9: ARIA, keyboard, and labels are in place
- [ ] R10: Pure helpers, effects only in hooks
- [ ] R11: Long docs/snippets externalized
- [ ] R12: Props have defaults; avoid boolean soups
- [ ] R13: Minimal state; memoization where beneficial
