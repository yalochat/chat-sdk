# Typescript Patterns and Guidelines

author: @Gago Frigerio

When invoked, review the current file or code under discussion and apply the following Yalo TypeScript patterns and guidelines. Point out violations and suggest improvements with concrete examples.

## The 💪 the types the weaker the 🪲

Typescript is as helpful as its types. **Avoid `any` types** — use `unknown` instead and narrow it with type guards.

### Replace `any` with `unknown`

before:
```tsx
function processAnything(value: any): void {
    console.log(value.toUpperCase());
}
```

after:
```tsx
function processUnknown(value: unknown): void {
    if (typeof value === 'string') {
        console.log(value.toUpperCase());
    } else {
        console.log("Unknown value type");
    }
}
```

### Avoid magic strings — use enums

before:
```tsx
function performActionByRole(role: string): void {
    if (role === "admin") { ... }
    else if (role === "user") { ... }
    else if (role === "guest") { ... }
}
```

after:
```tsx
enum USER_ROLE {
    ADMIN = "admin",
    USER = "user",
    GUEST = "guest",
}

function performActionByRole(role: USER_ROLE): void {
    if (role === USER_ROLE.ADMIN) { ... }
    else if (role === USER_ROLE.USER) { ... }
    else if (role === USER_ROLE.GUEST) { ... }
}
```

## ➖ logic ➕ data structures

Replace `if/else` chains and `switch` statements with data structures (maps, arrays of tuples) for better scalability, readability, and type safety.

### Map dispatch pattern

```tsx
type ActionByRoleMap = Record<USER_ROLE, (role: USER_ROLE) => void>;

const actionByRoleMap: ActionByRoleMap = {
  [USER_ROLE.ADMIN]: (role) => { /* admin action */ },
  [USER_ROLE.USER]:  (role) => { /* user action */ },
  [USER_ROLE.GUEST]: (role) => { /* guest action */ },
} as const;

function isValidRole(role: string): role is USER_ROLE {
   return role in USER_ROLE;
}

function performActionByRole(role: string = USER_ROLE.GUEST) {
   const definedRole = isValidRole(role) ? role : USER_ROLE.GUEST;
   return actionByRoleMap[definedRole](definedRole);
}
```

### Replace comparisons with `Array#includes`

before:
```tsx
if (USER_ROLE.USER == role && USER_ROLE.ADMIN == role) { ... }
```

after:
```tsx
const VALID_ROLES_FOR_X_CASE = [USER_ROLE.USER, USER_ROLE.ADMIN];
if (VALID_ROLES_FOR_X_CASE.includes(role)) { ... }
```

### Chain ifs → `Array#reduce` (apply all matching conditions)

```tsx
type Payload = {
  basicValues: Record<string, unknown>;
  expanded?: Record<string, unknown>;
};

type Actions = [
  test: (role: USER_ROLE) => boolean,
  action: (role: USER_ROLE, payload: Payload) => Payload
][];

const actionConfiguration: Actions = [
  [(role) => USER_ROLE.USER === role,       (role, payload) => { /* ... */ return payload; }],
  [(role) => isUserInAllowList(role),       (role, payload) => { /* ... */ return payload; }],
  [(role) => someOtherConsideration(role),  (role, payload) => { /* ... */ return payload; }],
];

const preparePayload = actionConfiguration.reduce((payload, [test, action]) => {
  return test(role) ? action(role, payload) : payload;
}, {} as Payload);
```

### First match → `Array#find`

```tsx
type Actions = [
  test: (role: USER_ROLE) => boolean,
  action: (role: USER_ROLE) => Payload
][];

const [, action] = actionConfiguration.find(([test]) => test(role))!;
return action(role);
```

## Guidelines Summary

When reviewing code, flag and fix:
1. `any` types → replace with `unknown` + type narrowing
2. Magic strings → replace with `enum`
3. Long `if/else` or `switch` chains → replace with map dispatch or tuple arrays
4. Repeated comparisons → replace with `Array#includes`
5. Sequential independent `if` blocks → replace with `Array#reduce`
6. First-match `if/else if` chains → replace with `Array#find`
