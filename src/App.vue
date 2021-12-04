<template>
  <button @click="this.start">Start</button>
  <button @click="this.stop">Stop</button>
  <p>Erkannt:</p>
  <p>{{text}}</p>
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
      final:'',
    };
  },
  methods: {
    start: function () {
      console.log('button');
      this.socket = io();

      // Connection opened
      this.socket.on('connect', () => {
        
        this.socket.on('recognize', (data) => {
          console.log('data', data);
          this.text = data;
        });

        this.socket.on('final', (data) => {
          console.log('data', data);
          this.final = data;
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
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
