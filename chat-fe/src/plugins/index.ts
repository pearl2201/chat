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
      url: import.meta.env.VITE_URL,
      store: pinia
    })
    .use(vuetify)
    .use(router)

}
