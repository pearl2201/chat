<template>
  
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

    }
  },
}
</script>
