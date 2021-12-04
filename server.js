const path = require('path');
const http = require('http');
const express = require('express');
const { Server } = require('socket.io');
const socketStream = require('socket.io-stream');
const ffmpegTranscoder = require('stream-transcoder');
const DeepSpeech = require('deepspeech');

const SERVER_PORT = 8080; // websocket server port

/*model*/
let DEEPSPEECH_MODEL = path.join('/models/', process.env.MODEL_NAME);

function createModel(modelDir) {
    let modelPath = modelDir + '.pbmm';
    let scorerPath = modelDir + '.scorer';
    let model = new DeepSpeech.Model(modelPath);
    model.enableExternalScorer(scorerPath);
    model.setBeamWidth(1024);
    return model;
}

//create server
const app = express();
const server = http.createServer(app);
const io = new Server(server);

//serve page
app.use('/', express.static(path.join(__dirname, 'dist')))

let model = createModel(DEEPSPEECH_MODEL);

io.on('connection', function(socket) {

    socketStream(socket).on('speech', function(stream) {

        let modelStream = model.createStream();

        new ffmpegTranscoder(stream)
            .sampleRate(16000)
            .channels(1)
            .custom('sample_fmt', 's16')
            .format('wav')
            .stream()
            .on('data', function(data) {
                modelStream.feedAudioContent(data);
                let transcript = modelStream.intermediateDecode();
                socket.emit('recognize', transcript);
            }).on('end', function() {
                DeepSpeech.FreeStream(modelStream);
            });
    });

    socket.once('disconnect', () => {
        console.log('client disconnected');
    });
});

server.listen(SERVER_PORT, () => {
    console.log(`Server listening on port ${SERVER_PORT}`);
});