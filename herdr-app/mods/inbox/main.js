// Inbox: agents that need you on top, finished ones as cards you put away by hand,
// working ones as quiet rows below. Based on the Inbox panel idea from
// dev.classmethod.jp (reona-herdr-app-herdr-core), written for this setup:
// two-line cards (task title, then space · branch) and words, not only colors, for status.

import { View, div, image, svg } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { agents, panes, theme, run, setAgentOrder, layout } from "herdr";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// The sidebar folds into a rail below 160px; the inbox draws dots then.
const narrow = () => (find(layout(), "sidebar")?.size?.px ?? Infinity) < 160;

const clean = (s) => (s ?? "").replace(/^[^\p{L}\p{N}]+/u, "").trim();

// The agent's own title (Claude Code: its current task), or null when it only
// says the program's name or a path.
function task(a) {
  const live = clean(a.title);
  if (!live || live === a.program?.name || live.toLowerCase() === a.program?.key) return null;
  if (/^[~/]|^[A-Za-z]:\\/.test((a.title ?? "").replace(/^[^\p{L}\p{N}~/]+/u, "")) || live.includes("@")) return null;
  return live;
}

function ago(ms) {
  const m = Math.floor(ms / 60000);
  if (m < 1) return "now";
  if (m < 60) return `${m}m`;
  const h = Math.floor(m / 60);
  return h < 24 ? `${h}h` : `${Math.floor(h / 24)}d`;
}

function icon(p, size, color) {
  if (!p?.icon) return null;
  return p.tint ? svg(p.icon).size(size).flex_none().text_color(color) : image(p.icon).w(size).h(size).flex_none();
}

// `vps/t7` is an agent on the machine "vps".
const machineOf = (a) => (a.address.includes("/") ? a.address.split("/")[0] : null);

const load = (key, fallback) => {
  try {
    return JSON.parse(localStorage.getItem(key) ?? "null") ?? fallback;
  } catch {
    return fallback;
  }
};

export default class Inbox extends View {
  init(_props, cx) {
    this.putAway = new Set(load("put-away", []));
    // When each agent entered its current state; done and idle count as one.
    this.since = load("since", {});
    this.showPutAway = false;
    this.hovered = null;
    // Only the "3m" labels need a clock; live data redraws by itself.
    cx.timer.every(30000, (cx) => cx.notify());
  }

  save() {
    localStorage.setItem("put-away", JSON.stringify([...this.putAway]));
    localStorage.setItem("since", JSON.stringify(this.since));
  }

  stamp(list, now) {
    let dirty = false;
    for (const a of list) {
      const s = a.status === "done" ? "idle" : a.status;
      if (this.since[a.address]?.s === s) continue;
      this.since[a.address] = { s, at: now };
      dirty = true;
    }
    // Put-away agents come back when they're gone or start something new.
    const live = new Map(list.map((a) => [a.address, a.status]));
    for (const addr of [...this.putAway]) {
      const s = live.get(addr);
      if (s === undefined || s === "working" || s === "blocked") {
        this.putAway.delete(addr);
        dirty = true;
      }
    }
    for (const [k, v] of Object.entries(this.since)) {
      if (!live.has(k) && now - v.at > 30 * 86400000) {
        delete this.since[k];
        dirty = true;
      }
    }
    if (dirty) this.save();
  }

  at(a) {
    return this.since[a.address]?.at ?? 0;
  }

  hover(id) {
    return (on, cx) => {
      if (on) this.hovered = id;
      else if (this.hovered === id) this.hovered = null;
      cx.notify();
    };
  }

  heading(t, label, n, color) {
    return h_flex()
      .px(8)
      .pt(10)
      .pb(4)
      .gap(6)
      .flex_none()
      .items_center()
      .text_size(11)
      .font_medium()
      .child(div().text_color(color).child(label))
      .child(div().text_color(t.dim).child(String(n)));
  }

  // "space · branch", with the machine for a remote agent.
  where(a) {
    const branch = this.branches.get(a.pane);
    return [machineOf(a), a.space_name, branch].filter(Boolean).join(" · ");
  }

  button(t, id, label, onClick) {
    return div()
      .id(id)
      .flex_none()
      .px(6)
      .h(18)
      .rounded(5)
      .flex()
      .items_center()
      .text_size(10)
      .text_color(t.muted)
      .bg(t.raised)
      .cursor_pointer()
      .hover((s) => s.bg(t.hover).text_color(t.foreground))
      .on_click((_e, cx) => {
        cx.stop_propagation();
        onClick();
        this.hovered = null;
        this.save();
        cx.notify();
      })
      .child(label);
  }

  // A card: three lines like a small message.
  //   icon  Title                      3m
  //   space · branch  [machine]
  //   Needs you / Finished      [Put away]
  card(t, a, now) {
    const blocked = a.status === "blocked";
    const tone = blocked ? t.blocked : t.done;
    const name = task(a) ?? a.tab_name ?? a.program?.name ?? a.address;
    const branch = this.branches.get(a.pane);
    const place = [a.space_name, branch].filter(Boolean).join(" · ");
    const machine = machineOf(a);
    const pic = icon(a.program, 14, t.foreground);
    return v_flex()
      .id(`card-${a.address}`)
      .mx(4)
      .my(4)
      .px(12)
      .py(10)
      .gap(6)
      .flex_none()
      .rounded(10)
      .border(1)
      .border_color(a.focused ? t.input : t.border)
      .bg(a.focused ? t.selected : t.surface)
      .cursor_pointer()
      .hover((s) => s.bg(t.hover))
      .on_click(() => run("pane.focus", { pane: a.pane }))
      .child(
        h_flex()
          .gap(7)
          .items_center()
          .when(Boolean(pic), (el) => el.child(pic))
          .child(div().flex_1().min_w(0).truncate().text_size(13).font_semibold().text_color(t.foreground).child(name))
          .child(div().flex_none().text_size(11).text_color(t.dim).child(ago(now - this.at(a)))),
      )
      .when(Boolean(place) || Boolean(machine), (el) =>
        el.child(
          h_flex()
            .gap(6)
            .items_center()
            .min_w(0)
            .when(Boolean(place), (el) => el.child(div().min_w(0).truncate().text_size(11.5).text_color(t.dim).child(place)))
            .when(Boolean(machine), (el) =>
              el.child(div().flex_none().px(6).h(18).rounded(5).bg(t.raised).flex().items_center().text_size(10.5).text_color(t.muted).child(machine)),
            ),
        ),
      )
      .child(
        h_flex()
          .h(22)
          .items_center()
          .justify_between()
          .child(div().text_size(11.5).font_medium().text_color(tone).child(blocked ? "Needs you" : "Finished"))
          .when(!blocked, (el) =>
            el.child(
              div()
                .id(`away-${a.address}`)
                .px(9)
                .h(22)
                .rounded(6)
                .border(1)
                .border_color(t.input)
                .flex()
                .items_center()
                .text_size(11)
                .text_color(t.muted)
                .cursor_pointer()
                .hover((s) => s.bg(t.raised).text_color(t.foreground))
                .on_click((_e, cx) => {
                  cx.stop_propagation();
                  this.putAway.add(a.address);
                  this.save();
                  cx.notify();
                })
                .child("Put away"),
            ),
          ),
      );
  }

  // A one-line row: working agents, and put-away ones when shown.
  row(t, a, now, away = false) {
    const id = `row-${a.address}`;
    const name = task(a) ?? a.tab_name ?? a.program?.name ?? a.address;
    const hovered = this.hovered === id;
    return h_flex()
      .id(id)
      .mx(4)
      .px(8)
      .h(26)
      .gap(8)
      .flex_none()
      .items_center()
      .rounded(7)
      .when(a.focused, (el) => el.bg(t.selected))
      .cursor_pointer()
      .hover((s) => s.bg(t.hover))
      .on_hover(this.hover(id))
      .on_click(() => run("pane.focus", { pane: a.pane }))
      .child(
        a.status === "working"
          ? svg("mods/workspace-chrome/spinner.svg").size(12).flex_none().text_color(t.working).spin(900)
          : div().size(7).mx(2).flex_none().rounded(4).border(1.5).border_color(t.idle ?? t.dim),
      )
      .child(div().flex_1().min_w(0).truncate().text_size(12).text_color(away ? t.muted : t.foreground).child(name))
      .child(
        away && hovered
          ? this.button(t, `back-${a.address}`, "Bring back", () => this.putAway.delete(a.address))
          : div().flex_none().max_w(70).truncate().text_size(10).text_color(t.dim).child(a.space_name ?? ""),
      );
  }

  // The folded sidebar: one status mark per agent, in inbox order.
  rail(t, order) {
    const mark = (a) => {
      if (a.status === "working") return svg("mods/workspace-chrome/spinner.svg").size(12).text_color(t.working).spin(900);
      if (a.status === "blocked") return div().size(14).rounded(4).bg(t.blocked + "26").text_size(10.5).font_bold().text_color(t.blocked).flex().items_center().justify_center().child("!");
      return div().size(7).rounded(4).bg(this.putAway.has(a.address) ? t.dim + "00" : t.done).border(1.5).border_color(t.done);
    };
    return v_flex()
      .size_full()
      .bg(t.chrome)
      .border_t(1)
      .border_color(t.border)
      .pt(8)
      .children(order.map((a) => h_flex()
        .id(`rail-${a.address}`)
        .h(26)
        .justify_center()
        .items_center()
        .when(a.focused, (el) => el.bg(t.selected))
        .hover((s) => s.bg(t.hover))
        .on_click(() => run("pane.focus", { pane: a.pane }))
        .child(mark(a))));
  }

  render() {
    const t = theme();
    const now = Date.now();
    const list = agents();
    this.stamp(list, now);
    this.branches = new Map(panes().map((p) => [p.pane, p.branch]));

    const newest = (x, y) => this.at(y) - this.at(x) || y.seq - x.seq;
    const needs = list.filter((a) => a.status === "blocked").sort(newest);
    const finished = list.filter((a) => (a.status === "done" || a.status === "idle") && !this.putAway.has(a.address)).sort(newest);
    const working = list.filter((a) => a.status === "working").sort(newest);
    const away = list.filter((a) => this.putAway.has(a.address)).sort(newest);
    const order = [...needs, ...finished, ...working, ...away];
    setAgentOrder(order.map((a) => a.address));

    if (narrow()) return this.rail(t, order);

    const empty = needs.length + finished.length + working.length === 0;
    return v_flex()
      .size_full()
      .min_h(0)
      .bg(t.chrome)
      .border_t(1)
      .border_color(t.border)
      .text_size(13)
      .child(
        h_flex()
          .px(16)
          .h(41)
          .pt(14)
          .pb(5)
          .flex_none()
          .items_center()
          .gap(6)
          .child(div().text_size(11.5).font_medium().text_color(t.dim).child("Inbox"))
          .when(needs.length > 0, (el) => el.child(div().px(5).h(15).rounded(4).flex().items_center().bg(t.blocked + "2e").text_size(10).font_semibold().text_color(t.blocked).child(String(needs.length)))),
      )
      .child(
        v_flex()
          .id("inbox-list")
          .flex_1()
          .min_h(0)
          .px(4)
          .pb(8)
          .overflow_y_scrollbar()
          .when(empty, (el) => el.child(div().px(12).pt(6).text_size(12).text_color(t.dim).child("Nothing to look at.")))
          .when(needs.length > 0, (el) => el.child(this.heading(t, "Needs you", needs.length, t.blocked)).children(needs.map((a) => this.card(t, a, now))))
          .when(finished.length > 0, (el) => el.child(this.heading(t, "Finished", finished.length, t.done)).children(finished.map((a) => this.card(t, a, now))))
          .when(working.length > 0, (el) => el.child(this.heading(t, "Working", working.length, t.working)).children(working.map((a) => this.row(t, a, now))))
          .when(away.length > 0, (el) =>
            el
              .child(
                h_flex()
                  .id("put-away-toggle")
                  .px(8)
                  .pt(10)
                  .pb(4)
                  .gap(6)
                  .flex_none()
                  .items_center()
                  .text_size(11)
                  .font_medium()
                  .text_color(t.dim)
                  .cursor_pointer()
                  .hover((s) => s.text_color(t.foreground))
                  .on_click((_e, cx) => {
                    this.showPutAway = !this.showPutAway;
                    cx.notify();
                  })
                  .child(`Put away ${this.showPutAway ? "▾" : "▸"}`)
                  .child(String(away.length)),
              )
              .when(this.showPutAway, (el) => el.children(away.map((a) => this.row(t, a, now, true))))),
      );
  }
}
