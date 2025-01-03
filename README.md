# pedometer

Provides access to the pedometer API on iOS and Android.

## Install

```bash
npm install pedometer
npx cap sync
```

## API

<docgen-index>

* [`start()`](#start)
* [`stop()`](#stop)
* [`isAvailable()`](#isavailable)
* [`getStepCount()`](#getstepcount)
* [`checkPermissions()`](#checkpermissions)
* [`requestPermissions()`](#requestpermissions)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### start()

```typescript
start() => Promise<void>
```

--------------------


### stop()

```typescript
stop() => Promise<void>
```

--------------------


### isAvailable()

```typescript
isAvailable() => Promise<{ available: boolean; }>
```

**Returns:** <code>Promise&lt;{ available: boolean; }&gt;</code>

--------------------


### getStepCount()

```typescript
getStepCount() => Promise<{ steps: number; }>
```

**Returns:** <code>Promise&lt;{ steps: number; }&gt;</code>

--------------------


### checkPermissions()

```typescript
checkPermissions() => Promise<PermissionState>
```

**Returns:** <code>Promise&lt;<a href="#permissionstate">PermissionState</a>&gt;</code>

--------------------


### requestPermissions()

```typescript
requestPermissions() => Promise<void>
```

--------------------


### Type Aliases


#### PermissionState

<code>'prompt' | 'prompt-with-rationale' | 'granted' | 'denied'</code>

</docgen-api>
