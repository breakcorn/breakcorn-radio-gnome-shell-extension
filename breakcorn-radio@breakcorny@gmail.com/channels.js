import GObject from "gi://GObject";
import Gio from "gi://Gio";
import St from "gi://St";
import Clutter from "gi://Clutter";

import * as PopupMenu from "resource:///org/gnome/shell/ui/popupMenu.js";

import * as Data from "./data.js";
import { extPath } from "./extension.js";

export const channels = [
  {
    name: "Breakcorn Radio",
    link: "https://stream.breakcorn.ru/main",
    pic: "/images/breakcorn.png",
    num: 0,
  },
  {
    name: "Breakcorn Radio (Mezzo)",
    link: "https://stream.breakcorn.ru/mezzo",
    pic: "/images/breakcorn.png",
    num: 1,
  },
  {
    name: "Breakcore Mashcore Radio.Mosco.win",
    link: "https://radio.mosco.win/play",
    pic: "/images/breakcorn.png",
    num: 2,
  },
  {
    name: "Nautic Radio Groningen",
    link: "http://stream.nauticradio.net:14280/",
    pic: "/images/breakcorn.png",
    num: 3,
  },
  {
    name: "Radio Schizoid - PsyTrance - Tune in for the best Psytrance/GoaTrance beats.",
    link: "http://94.130.113.214:8000/chill",
    pic: "/images/breakcorn.png",
    num: 4,
  },
  {
    name: "Radio Schizoid - Chillout / Ambient - Finest Psychedelic Chillout/Ambient Tunes.",
    link: "http://94.130.113.214:8000/dubtechno",
    pic: "/images/breakcorn.png",
    num: 5,
  },
  {
    name: "Radio Schizoid - Dub Techno - Our new channel and my favorite.",
    link: "http://94.130.113.214:8000/prog",
    pic: "/images/breakcorn.png",
    num: 6,
  },
  {
    name: "Radio Schizoid - Progressive Psy - Only the best of Progressive Psytrance",
    link: "http://94.130.113.214:8000/schizoid",
    pic: "/images/breakcorn.png",
    num: 7,
  },
];

const holidayChannels = [];

export const Channel = class Channel {
  constructor(name, link, pic, num, fav) {
    this.name = name;
    this.link = link;
    this.pic = pic;
    this.num = num;
    this.fav = fav;
  }

  getName() {
    return this.name;
  }

  getLink() {
    return this.link;
  }

  getPic() {
    return this.pic;
  }

  getNum() {
    return this.num;
  }

  isFav() {
    return this.fav;
  }

  setFav(f) {
    this.fav = f;
  }
};

export const ChannelBox = GObject.registerClass(
  class ChannelBox extends PopupMenu.PopupBaseMenuItem {
    _init(channel, player, popup) {
      super._init({
        reactive: true,
        can_focus: true,
      });
      this.player = player;
      this.channel = channel;
      this.popup = popup;

      this.vbox = new St.BoxLayout({ vertical: false });
      this.add_child(this.vbox);

      let icon2 = new St.Icon({
        gicon: Gio.icon_new_for_string(extPath + channel.getPic()),
        style: "margin-right:10px",
        icon_size: 60,
      });

      let box2 = new St.BoxLayout({ vertical: false });
      let label1 = new St.Label({
        text: channel.getName(),
        y_align: Clutter.ActorAlign.CENTER,
        y_expand: true,
      });
      this.vbox.add_child(icon2);
      this.vbox.add_child(box2);
      box2.add_child(label1);
    }

    activate(ev) {
      this.player.stop();
      this.player.setChannel(this.channel);
      this.player.play();
      this.popup.channelChanged();
    }
  },
);

export function getChannels() {
  const isDecember = new Date().getMonth() === 11;
  const allChannels = isDecember ? [...channels, ...holidayChannels] : channels;
  return allChannels.map(
    (ch) => new Channel(ch.name, ch.link, ch.pic, ch.num, Data.isFav(ch.num)),
  );
}

export function getFavChannels() {
  return getChannels()
    .filter((ch) => Data.isFav(ch.num))
    .map((ch) => new Channel(ch.name, ch.link, ch.pic, ch.num, true));
}

export function getChannel(index) {
  let item = getChannels()[index] ?? getChannels()[0];
  return new Channel(
    item.name,
    item.link,
    item.pic,
    item.num,
    Data.isFav(item.num),
  );
}
