import type { PermissionState } from "@capacitor/core";

export interface PedometerPlugin {
  start(): Promise<void>;
  stop(): Promise<void>;
  isAvailable(): Promise<{ available: boolean }>;
  getStepCount(): Promise<{ steps: number }>;
  checkPermissions(): Promise<PermissionState>;
  requestPermissions(): Promise<void>;
}