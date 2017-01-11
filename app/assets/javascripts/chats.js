/**
 * Created by Sambit Mohanty on 1/11/17.
 * This file contains scripts to connect and communicate with different nodes in WebSocket
 */

var webSocket, sender;
var sProtocole;

if (window.location.protocol == "http:") {
    sProtocole = "ws://";
} else {
    sProtocole = "wss://";
}
var host = window.location.hostname;
var port = (window.location.port == "") ? "" : (":" + window.location.port);
var socketURL = sProtocole + host + port + "/";

// $(function () {
//     window.Notification.requestPermission(function () {
//         console.log('Permissions state: ' + window.Notification.permission);
//     });
// });

function initializeWebSocket(channel) {
    var ws = new WebSocket(socketURL + channel);
    console.log("Websocket initialized: " + ws.url);
    ws.onmessage = function (event) {
        console.log("First message received..." + event.data);
        displayChatMessage(event.data);
    };
}

function subscribeChannel(channel, userId) {
    console.log("=============================== Function subscribeChannel ===============================");
    sender = userId;
    if (webSocket) webSocket.close();
    webSocket = new WebSocket(socketURL + channel);
    console.log(webSocket);
    webSocket.onmessage = function (event) {
        console.log("xxxxxxxxxxxxxxxxxxxxxxxxxxxx Message Received xxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        console.log("Message received on other member's Individual channel (from subscribeChannel function): " + event.data);
        displayChatMessage(event.data);
    };
}


function sendMessage() {
    console.log("=============================== Function sendMessage ===============================");
    var textArea = $("#chat-message");
    var message = $.trim(textArea.val());
    if (message == "") return false;
    message += "|~|" + sender;
    console.log("Message before send: " + message);
    webSocket.send(message);
    textArea.val('');
}

function sendMessageText(event) {
    console.log("=============================== Function sendMessageText ===============================");
    if (event.keyCode == 13) {
        $("#send-message").trigger("click");
        return false;
    }
    return true;
}

function generateHtml(content) {
    var html = "";
    html += "<p>" + content["sender"] + ": " + content["message"] + "</p>"
    return html;
}

function displayChatMessage(data) {
    var content = JSON.parse(data);
    var chatBody = $("#message-content");
    chatBody.append(generateHtml(content));
}
