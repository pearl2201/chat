/**
 * plugins/index.ts
 *
 * Automatically included in `./src/main.ts`
 */

// Plugins
import vuetify from './vuetify'
import pinia from '../stores'
import router from '../router'
import channel from './phoenix-channels'
// Types
import type { App } from 'vue'
pinia.use(({ options,store }) => {
  console.log(options, store);
});
export function registerPlugins (app: App) {
  app
  .use(pinia)
    .use(channel, {
      url: 'ws://localhost:4000/socket',
      store: pinia
    })
    .use(vuetify)
    .use(router)

}
