// Utilities
import { defineStore } from 'pinia'

export const useRoomStore = defineStore('app', {
  state: () => ({
    //
    rooms: []
  }),
  actions: {
    init($socket)
    {
        console.log($socket);
    }
  },
  channels: {
    init: {
        on_def(){
            
        }
    }
  }
})
