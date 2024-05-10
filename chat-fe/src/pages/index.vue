<template>
  <div v-if="status == 0" class="d-flex align-center justify-center h-100">
    <v-sheet class="mx-auto" width="300">
      <v-form @submit.prevent="onSubmitUsername">
        <v-text-field v-model="username" :rules="rules" label="User name"></v-text-field>
        <v-btn class="mt-2" type="submit" block>Submit</v-btn>
      </v-form>
    </v-sheet>
  </div>
  <div v-if="status == 1" class="d-flex align-center justify-center h-100">
    <v-row>
      <v-col cols="8"></v-col>
      <v-col cols="4">
        <v-dialog max-width="500" v-model="createRoomDialog">
          <template v-slot:activator="{ props: activatorProps }">
            <v-btn v-bind="activatorProps" color="surface-variant" text="Open Dialog" variant="flat">Add room</v-btn>
          </template>

          <template v-slot:default="{ isActive }">
            <v-card title="Create room">
              <v-card-text>

                <v-text-field v-model="createRoomItem.name" :rules="rules" label="Room name"></v-text-field>

              </v-card-text>

              <v-card-actions>
                <v-spacer></v-spacer>

                <v-btn text="Cancel" @click="isActive.value = false"></v-btn>
                <v-btn text="Create" @click.prevent="createRoom"></v-btn>

              </v-card-actions>
            </v-card>
          </template>
        </v-dialog>
        <v-infinite-scroll :height="300" :items="rooms">
          <template v-for="(item, index) in items" :key="item">
            <div :class="['pa-2', index % 2 === 0 ? 'bg-grey-lighten-2' : '']">
              Item number #{{ item }}
            </div>
          </template>
        </v-infinite-scroll>

      </v-col>
    </v-row>
  </div>


</template>

<script lang="ts">
import { useRoomStore } from '../stores/room';



export default {
  setup() {
    const roomStore = useRoomStore();
    return { roomStore };
  },
  mounted() {
    this.roomStore.init(this.$netClient);
  },
  data() {
    return {
      username: '',
      createRoomDialog: false,
      createRoomItem: {
        name: ''
      },
      status: 0,
      loading: true,
      rules: [
        value => {
          if (value) return true

          return 'You must enter a username.'
        },
      ],
      load: false,
      rooms: []
    }
  },
  methods: {
    onSubmitUsername() {
      this.status = 1;
      this.$netClient.connect(this.username);
      var lobbyChannel = this.$netClient.joinLobby();
      lobbyChannel.on("update_roomlist", (payload) => {
        console.log(payload)
      })

      lobbyChannel.push("get_roomlist")
        .receive("ok", payload => console.log("phoenix replied:", payload))
        .receive("error", err => console.log("phoenix errored", err))
        .receive("timeout", () => console.log("timed out pushing"))
    },
    createRoom() {

    }

  }
}
</script>

<style>
.loading-screen {
  position: absolute;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  z-index: 9999;
}
</style>