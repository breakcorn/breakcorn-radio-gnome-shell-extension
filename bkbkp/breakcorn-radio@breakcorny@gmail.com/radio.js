// imports.gi.versions.Gst = "1.0";
// imports.gi.versions.GstAudio = "1.0";
import Gst from "gi://Gst";
import GstAudio from "gi://GstAudio";

import GObject from "gi://GObject";
import St from "gi://St";
import Clutter from "gi://Clutter";

import * as Channels from "./channels.js";
import * as Data from "./data.js";
import GLib from "gi://GLib";

const DEFAULT_VOLUME = 0.5;
const CLIENT_NAME = "breakcorn-radio";

// Connection states
const ConnectionState = {
    STOPPED: 'stopped',
    CONNECTING: 'connecting', 
    PLAYING: 'playing',
    RECONNECTING: 'reconnecting',
    ERROR: 'error'
};

export const ControlButtons = GObject.registerClass(
    {
        GTypeName: "ControlButtons",
    },
    class ControlButtons extends St.BoxLayout {
        _init(player, pr) {
            super._init({
                vertical: false,
                x_align: Clutter.ActorAlign.CENTER,
                x_expand: true,
            });

            this.prev = new St.Icon({
                style_class: "icon",
                icon_name: "media-skip-backward-symbolic",
                reactive: true,
                icon_size: 25,
            });

            this.icon = new St.Icon({
                style_class: "icon",
                icon_name: "media-playback-start-symbolic",
                reactive: true,
            });

            this.next = new St.Icon({
                style_class: "icon",
                icon_name: "media-skip-forward-symbolic",
                reactive: true,
                icon_size: 25,
            });

            this.add_child(this.prev);
            this.add_child(this.icon);
            this.add_child(this.next);

            this.player = player;
            this.playing = false;
            this.pr = pr;

            this.next.connect("button-press-event", () => {
                this.player.stop();
                this.player.next();
                this.player.play();
                this.pr.channelChanged();
            });

            this.prev.connect("button-press-event", () => {
                this.player.stop();
                this.player.prev();
                this.player.play();
                this.pr.channelChanged();
            });

            this.icon.connect("button-press-event", () => {
                if (this.playing) {
                    this.player.stop();
                    this.icon.set_icon_name("media-playback-start-symbolic");
                    this.pr.setLoading(false);
                    this.pr.desc.set_text("Breakcorn Radio");
                } else {
                    this.player.play();
                    this.icon.set_icon_name("media-playback-stop-symbolic");
                    this.pr.setLoading(false);
                    this.pr.setLoading(true);
                    if (this.pr.err != null) this.pr.err.destroy();
                }

                this.playing = !this.playing;
            });
        }
    },
);

export const RadioPlayer = class RadioPlayer {
    constructor(channel) {
        console.log("Breakcorn Radio: Initializing RadioPlayer for channel:", channel.name);
        try {
            console.log("Breakcorn Radio: Initializing GStreamer...");
            Gst.init(null);
            
            console.log("Breakcorn Radio: Creating playbin element...");
            this.playbin = Gst.ElementFactory.make("playbin", "breakcorn");
            if (!this.playbin) {
                throw new Error("Failed to create playbin element - GStreamer playbin plugin not available");
            }
            
            console.log("Breakcorn Radio: Setting URI:", channel.getLink());
            this.playbin.set_property("uri", channel.getLink());
            
            console.log("Breakcorn Radio: Creating pulsesink element...");
            this.sink = Gst.ElementFactory.make("pulsesink", "sink");
            if (!this.sink) {
                throw new Error("Failed to create pulsesink element - GStreamer PulseAudio plugin not available");
            }
            
            console.log("Breakcorn Radio: RadioPlayer initialized successfully");
        } catch (error) {
            console.error("Breakcorn Radio: Failed to initialize GStreamer:", error.message);
            console.error("Breakcorn Radio: Make sure GStreamer and plugins are installed:");
            console.error("Breakcorn Radio: sudo apt install gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-pulseaudio");
            throw error;
        }

        this.sink.set_property("client-name", CLIENT_NAME);
        this.playbin.set_property("audio-sink", this.sink);
        this.channel = channel;
        this.setVolume(DEFAULT_VOLUME);
        this.tag = "Breakcorn Radio";

        // Connection state and reconnection
        this.connectionState = ConnectionState.STOPPED;
        this.reconnectionAttempts = 0;
        this.maxReconnectionAttempts = 5;
        this.reconnectionTimer = null;
        this.userStopped = false; // Flag to distinguish user stop from error

        let bus = this.playbin.get_bus();
        bus.add_signal_watch();
        bus.connect("message", (bus, msg) => {
            if (msg != null) this._onMessageReceived(msg);
        });
        this.onError = null;
        this.onTagChanged = null;
    }

    play() {
        this.userStopped = false;
        this._cancelReconnection();
        this._setState(ConnectionState.CONNECTING);
        this.playbin.set_state(Gst.State.PLAYING);
        this.playing = true;
    }

    setOnError(onError) {
        this.onError = onError;
    }

    setOnTagChanged(onTagChanged) {
        this.onTagChanged = onTagChanged;
    }

    setMute(mute) {
        this.playbin.set_property("mute", mute);
    }

    stop() {
        this.playbin.set_state(Gst.State.NULL);
        this.playing = false;
        this.tag = "Breakcorn Radio";
    }

    next() {
        let num = this.channel.getNum();
        num = num >= Channels.channels.length - 1 ? 0 : num + 1;
        this.setChannel(Channels.getChannel(num));
    }

    prev() {
        let num = this.channel.getNum();
        num = num <= 0 ? Channels.channels.length - 1 : num - 1;
        this.setChannel(Channels.getChannel(num));
    }

    setChannel(ch) {
        this.channel = ch;
        this._cancelReconnection();
        this.reconnectionAttempts = 0;
        this.stop();
        this.playbin.set_property("uri", ch.getLink());
        this.play();
    }

    getChannel() {
        return this.channel;
    }

    setVolume(value) {
        //this.playbin.set_volume(GstAudio.StreamVolumeFormat.LINEAR, value);
        this.playbin.volume = value;
    }

    isPlaying() {
        return this.playing;
    }

    getTag() {
        return this.tag;
    }

    
    getConnectionState() {
        return this.connectionState;
    }
    
    getReconnectionAttempts() {
        return this.reconnectionAttempts;
    }
    
    getMaxReconnectionAttempts() {
        return this.maxReconnectionAttempts;
    }
    
    cancelReconnection() {
        this._cancelReconnection();
        if (this.connectionState === ConnectionState.RECONNECTING) {
            this._setState(ConnectionState.ERROR);
        }
    }
    
    // Callbacks setters
    setOnStateChanged(callback) {
        this.onStateChanged = callback;
    }
    
    setOnReconnectionStarted(callback) {
        this.onReconnectionStarted = callback;
    }
    
    setOnReconnectionAttempt(callback) {
        this.onReconnectionAttempt = callback;
    }
    
    setOnReconnectionFailed(callback) {
        this.onReconnectionFailed = callback;
    }

    _onMessageReceived(msg) {
        switch (msg.type) {
            case Gst.MessageType.TAG:
                let tagList = msg.parse_tag();
                let tmp = tagList.get_string("title");
                let tag = tmp[1];
                this.tag = tag;
                if (this.onTagChanged != null) this.onTagChanged();
                break;

            case Gst.MessageType.STREAM_START:
                this._setState(ConnectionState.PLAYING);
                this.reconnectionAttempts = 0; // Reset attempts on successful connection
                if (this.onTagChanged != null) this.onTagChanged();
                break;

            // Both should do the same thing
            case Gst.MessageType.EOS:
            case Gst.MessageType.ERROR:
                if (!this.userStopped) {
                    this._handleConnectionError();
                } else {
                    this.stop();
                    if (this.onError != null) this.onError();
                }
                break;
            default:
                break;
        }
    }
    
    _loadReconnectionSettings() {
        const settings = Data.getReconnectionSettings();
        this.reconnectionEnabled = settings.enabled;
        this.maxReconnectionAttempts = settings.maxAttempts;
        this.baseReconnectionDelay = settings.baseDelay;
        this.maxReconnectionDelay = settings.maxDelay;
    }
    
    _setState(newState) {
        if (this.connectionState !== newState) {
            this.connectionState = newState;
            if (this.onStateChanged != null) {
                this.onStateChanged(newState);
            }
        }
    }
    
    _handleConnectionError() {
        this.playbin.set_state(Gst.State.NULL);
        this.playing = false;
        
        if (this.reconnectionEnabled && this.reconnectionAttempts < this.maxReconnectionAttempts) {
            this._startReconnection();
        } else {
            this._setState(ConnectionState.ERROR);
            if (this.onError != null) this.onError();
        }
    }
    
    _startReconnection() {
        this._setState(ConnectionState.RECONNECTING);
        this.reconnectionAttempts++;
        
        if (this.onReconnectionStarted != null) {
            this.onReconnectionStarted(this.reconnectionAttempts, this.maxReconnectionAttempts);
        }
        
        // Calculate delay with exponential backoff
        const delay = Math.min(
            this.baseReconnectionDelay * Math.pow(2, this.reconnectionAttempts - 1),
            this.maxReconnectionDelay
        );
        
        this.reconnectionTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, delay, () => {
            this._attemptReconnection();
            return GLib.SOURCE_REMOVE;
        });
    }
    
    _attemptReconnection() {
        if (this.onReconnectionAttempt != null) {
            this.onReconnectionAttempt(this.reconnectionAttempts, this.maxReconnectionAttempts);
        }
        
        // Try to reconnect
        this.playbin.set_property("uri", this.channel.getLink());
        this.playbin.set_state(Gst.State.PLAYING);
        this.playing = true;
        
        this.reconnectionTimer = null;
    }
    
    _cancelReconnection() {
        if (this.reconnectionTimer != null) {
            GLib.source_remove(this.reconnectionTimer);
            this.reconnectionTimer = null;
        }
    }
};
