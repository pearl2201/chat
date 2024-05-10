<template>
  <v-app>
    <v-main>
      <router-view />
    </v-main>
  </v-app>
</template>

<script lang="ts">

export default{
  mounted(){
    console.log(this.$state);
  }
}


</script>
