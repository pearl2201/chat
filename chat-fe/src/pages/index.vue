<template>
  <div v-if="status == 0" class="d-flex align-center justify-center h-100">
    <v-sheet class="mx-auto" width="300">
      <v-form @submit.prevent="onSubmitUsername">
        <v-text-field
          v-model="username"
          :rules="rules"
          label="User name"
        ></v-text-field>
        <v-btn class="mt-2" type="submit" block>Submit</v-btn>
      </v-form>
    </v-sheet>
  </div>
  <div v-if="status == 1" class="d-flex justify-center h-100">
    <v-row>
      <v-col cols="3">
        <v-card class="mx-auto h-100" max-width="500" border flat>
          <v-list-item class="px-6" height="88">
            <template v-slot:prepend>
              <v-avatar color="surface-light" size="32">🎯</v-avatar>
            </template>

            <template v-slot:title> Rooms </template>

            <template v-slot:append>
              <v-dialog max-width="500" v-model="createRoomDialog">
                <template v-slot:activator="{ props: activatorProps }">
                  <v-btn
                    v-bind="activatorProps"
                    color="surface-variant"
                    text="Open Dialog"
                    variant="flat"
                    >Add room</v-btn
                  >
                </template>

                <template v-slot:default="{ isActive }">
                  <v-card title="Create room">
                    <v-card-text>
                      <v-text-field
                        v-model="createRoomItem.name"
                        :rules="rules"
                        label="Room name"
                      ></v-text-field>
                    </v-card-text>

                    <v-card-actions>
                      <v-spacer></v-spacer>

                      <v-btn
                        text="Cancel"
                        @click="isActive.value = false"
                      ></v-btn>
                      <v-btn text="Create" @click.prevent="createRoom"></v-btn>
                    </v-card-actions>
                  </v-card>
                </template>
              </v-dialog>
            </template>
          </v-list-item>

          <v-divider></v-divider>

          <v-card-text class="text-medium-emphasis pa-0">
            <v-virtual-scroll :items="rooms" active-color="blue">
              <template v-slot:default="{ item }">
                <v-list-item
                  class="border-t"
                  height="60"
                  :class="{
                    'active-room-item': item.room_id == this.currentRoomId,
                  }"
                  @click.prevent="change_room(item.room_id)"
                >
                  <v-list-item-title>{{ item.room_name }}</v-list-item-title>
                </v-list-item>
              </template>
            </v-virtual-scroll>
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="9"></v-col>
    </v-row>
  </div>
</template>

<script lang="ts">
import { useRoomStore } from "../stores/room";

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
      username: "",
      createRoomDialog: false,
      createRoomItem: {
        name: "",
      },
      status: 0,
      loading: true,
      rules: [
        (value: any) => {
          if (value) return true;

          return "You must enter a username.";
        },
      ],
      load: false,
      rooms: [],
      lobbyChannel: null,
      currentRoomId: null,
      currentRoom: null,
      currentRoomData: {
        room_id: -1,
        room_name: "",
        members: [],
        messages: [],
      },
    };
  },
  methods: {
    onSubmitUsername() {
      this.status = 1;
      this.$netClient.connect(this.username);
      this.lobbyChannel = this.$netClient.joinLobby();
      this.lobbyChannel.on("add_roomlist", (payload) => {
        console.log("add_roomlist: ", payload);
        this.rooms.push(payload);
      });

      this.lobbyChannel
        .push("get_roomlist")
        .receive("ok", (payload) => {
          this.rooms = payload;
        })
        .receive("error", (err) => console.log("phoenix errored", err))
        .receive("timeout", () => console.log("timed out pushing"));
    },
    createRoom() {
      this.createRoomDialog = false;
      this.lobbyChannel
        .push("create_room", { room_name: this.createRoomItem.name })
        .receive("ok", (payload) => {
          console.log(payload);
          this.currentRoomId = payload.room_id;
          console.log("currentRoomId: ", this.currentRoomId);
          this.currentRoom = this.$netClient.joinRoom(this.currentRoomId);

          this.currentRoom.on("user_join", (payload) => {
            console.log("user_join: ", payload);
            this.currentRoomData.members.push(payload);
          });

          this.currentRoom.on("room_detail", (payload) => {
            console.log("room_detail: ", payload);
            this.currentRoomData = payload;
          });

          this.currentRoom.on("new_message", (payload) => {
            console.log("new_message: ", payload);
            this.currentRoomData.messages.push(payload);
          });
        })
        .receive("error", (err) => console.log("phoenix errored", err))
        .receive("timeout", () => console.log("timed out pushing"));
    },

    change_room(room_id: number) {
      if (this.currentRoom != null) {
        this.currentRoom.leave(1000);
      }

      this.currentRoomId = room_id;
      console.log("currentRoomId: ", this.currentRoomId);
      this.currentRoom = this.$netClient.joinRoom(this.currentRoomId);

      this.currentRoom.on("user_join", (payload) => {
        console.log("user_join: ", payload);
        this.currentRoomData.members.push(payload);
      });

      this.currentRoom.on("room_detail", (payload) => {
        console.log("room_detail: ", payload);
        this.currentRoomData = payload;
      });

      this.currentRoom.on("new_message", (payload) => {
        console.log("new_message: ", payload);
        this.currentRoomData.messages.push(payload);
      });
    },
  },
};
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

.active-room-item {
  background-color: aqua;
}
</style>