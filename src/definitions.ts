export interface PedometerPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
