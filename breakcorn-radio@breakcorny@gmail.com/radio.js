// imports.gi.versions.Gst = "1.0";
// imports.gi.versions.GstAudio = "1.0";
import Gst from "gi://Gst";
import GstAudio from "gi://GstAudio";

import GObject from "gi://GObject";
import St from "gi://St";
import Clutter from "gi://Clutter";

import * as Channels from "./channels.js";

const DEFAULT_VOLUME = 0.5;
const CLIENT_NAME = "breakcorn-radio";

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
        Gst.init(null);
        this.playbin = Gst.ElementFactory.make("playbin", "breakcorn");
        this.playbin.set_property("uri", channel.getLink());
        this.sink = Gst.ElementFactory.make("pulsesink", "sink");

        this.sink.set_property("client-name", CLIENT_NAME);
        this.playbin.set_property("audio-sink", this.sink);
        this.channel = channel;
        this.setVolume(DEFAULT_VOLUME);
        this.tag = "Breakcorn Radio";

        let bus = this.playbin.get_bus();
        bus.add_signal_watch();
        bus.connect("message", (bus, msg) => {
            if (msg != null) this._onMessageReceived(msg);
        });
        this.onError = null;
        this.onTagChanged = null;
    }

    play() {
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
                if (this.onTagChanged != null) this.onTagChanged();
                break;

            // Both should do the same thing
            case Gst.MessageType.EOS:
            case Gst.MessageType.ERROR:
                this.stop();
                if (this.onError != null) this.onError();
                break;
            default:
                break;
        }
    }
};
