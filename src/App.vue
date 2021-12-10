<template>
  <main>
    <button @click="this.button">
      <img v-if="!(recorder?.state == 'recording')" class="icon" src="@/assets/mic.svg" alt="Start Recording">
      <img v-else src="@/assets/stop.svg" class="icon" alt="Stop Recording">
    </button>
    <span>Transcript:</span>
    <p>{{text}}</p>
  </main>
</template>

<script>
import io from 'socket.io-client';
import ss from 'socket.io-stream';

export default {
  name: 'App',
  data() {
    return {
      socket: null,
      recorder: null,
      stream:null,
      text: '',
    };
  },
  methods: {
    button: function() {
      if(this.recorder?.state == 'recording') {
        this.stop();
      } else {
        this.start();
      }
    },
    start: function () {
      this.socket = io();

      // Connection opened
      this.socket.on('connect', () => {
        
        this.socket.on('recognize', (data) => {
          console.log('data', data);
          this.text = data;
        });

        navigator.mediaDevices.getUserMedia({audio:{
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
          volume: 1,
        }}).then(stream => {

          this.recorder = new MediaRecorder(stream);

          this.stream = ss.createStream();
          ss(this.socket).emit('speech', this.stream );

          this.recorder.ondataavailable = async event => {
            console.log(event);
            this.stream.write(new ss.Buffer(await event.data.arrayBuffer()));
          };
          this.recorder.start(1000);
        });
      });
    },
    stop: function () {
      this.recorder.stop();
      this.stream.end();
      //this.stream.end();
    },
  }
}
</script>

<style>
@import url(https://static.caesi.dev/css/general.css);

* {
  padding:0px;
  margin:0px;
}

#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: var(--text-color);
  width: 100vw;
  height: 100vh;
  background-color: var(--background-color);
}

main {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 80%;
}

button {
  border-radius: 100%;
  aspect-ratio: 1;
  padding: 20px;
  border: solid 2px white;
  background: transparent;
  cursor: pointer;
}

button:hover {
  background-color: red;
}

button img {
  display: flex;
  width: 100%;
  height: 100%;
  object-fit: contain;
}

span {
  font-weight: bold;
  padding: 20px;
}

@media (prefers-color-scheme: light) {
  .icon {
    filter: invert(100%);
  }
}



</style>
