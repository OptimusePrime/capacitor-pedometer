import { WebPlugin } from '@capacitor/core';

import type { PedometerPlugin } from './definitions';

export class PedometerWeb extends WebPlugin implements PedometerPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}
