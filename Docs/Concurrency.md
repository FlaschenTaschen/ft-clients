# Concurrency

Never use Combine or Dispatch for concurrency. Always use modern Swift Concurrency.

## Non-blocking

Code should no block the current thread. Instead we should Task with Task.sleep with a duration which does not block threads. It can call functions or closures which resume execution.

## Sleeping

Never use `Task.sleep(nanoseconds: UInt64(delayMs) * 1_000_000)` and instead use `Duration` which is done with `Task.sleep(for: .seconds(1))`.
