// Zellij 風のモード。keys.json の ctrl-p / ctrl-t / ctrl-h / ctrl-s / ctrl-o が
// それぞれ zj-pane / zj-tab / zj-move / zj-scroll / zj-session を開き、次の 1 キーを受け取る。
// stay: true の行は押してもモードに留まる(Esc / Enter / 同じ ctrl キーで抜ける)。
// 元の割り当ては ~/.config/zellij/config.kdl。Herdr に相当機能が無いものは載せていない。
// このファイルは zj-* の 5 フォルダに同じ内容で置いてある。直すときは 5 つとも揃える。
import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, openOverlay, focused, theme } from "herdr";

const go = (direction) => () => run("pane.go", { direction });
const swap = (direction) => () => run("pane.swap", { direction });
const scroll = (args) => (at) => run("terminal.scroll", { ...args, terminal: at?.terminal ?? undefined });
const worktree = (action, width, height, extra = {}) => (at) =>
  openOverlay({ mod: "worktree", kind: "dialog", width, height, props: { space: at?.space, folder: at?.cwd, action, ...extra } });

const MODES = {
  pane: {
    title: "PANE",
    leave: "ctrl-p",
    rows: [
      { on: ["h", "left"], show: "h ←", label: "左のペインへ", stay: true, run: go("left") },
      { on: ["j", "down"], show: "j ↓", label: "下のペインへ", stay: true, run: go("down") },
      { on: ["k", "up"], show: "k ↑", label: "上のペインへ", stay: true, run: go("up") },
      { on: ["l", "right"], show: "l →", label: "右のペインへ", stay: true, run: go("right") },
      { on: ["r", "n"], show: "r n", label: "右に分割", run: () => run("pane.split", { direction: "right" }) },
      { on: ["d"], show: "d", label: "下に分割", run: () => run("pane.split", { direction: "down" }) },
      { on: ["f"], show: "f", label: "ズーム切り替え", run: () => run("pane.zoom", {}) },
      { on: ["x"], show: "x", label: "ペインを閉じる", run: () => run("pane.close", {}) },
    ],
  },
  tab: {
    title: "TAB",
    leave: "ctrl-t",
    rows: [
      { on: ["h", "k", "left"], show: "h k ←", label: "前のタブ", stay: true, run: () => run("tab.prev", {}) },
      { on: ["l", "j", "right"], show: "l j →", label: "次のタブ", stay: true, run: () => run("tab.next", {}) },
      { on: ["1", "2", "3", "4", "5", "6", "7", "8", "9"], show: "1-9", label: "番号のタブへ", run: (_at, key) => run("tab.select", { index: Number(key) }) },
      { on: ["n"], show: "n", label: "新しいタブ", run: () => run("tab.new", {}) },
      { on: ["r"], show: "r", label: "タブ名を変更", run: (at) => run("tab.rename", { id: at?.tab }) },
      { on: ["x"], show: "x", label: "タブを閉じる", run: () => run("tab.close", {}) },
      { on: ["w"], show: "w", label: "worktree を開く", run: worktree("open", 560, 480) },
      { on: ["c"], show: "c", label: "worktree を作る", run: worktree("new", 460, 280) },
      { on: ["a"], show: "a", label: "worktree + Claude", run: worktree("new", 460, 280, { argv: ["claude"] }) },
    ],
  },
  move: {
    title: "MOVE",
    leave: "ctrl-h",
    rows: [
      { on: ["h", "left"], show: "h ←", label: "ペインを左と入れ替え", stay: true, run: swap("left") },
      { on: ["j", "down"], show: "j ↓", label: "ペインを下と入れ替え", stay: true, run: swap("down") },
      { on: ["k", "up"], show: "k ↑", label: "ペインを上と入れ替え", stay: true, run: swap("up") },
      { on: ["l", "right"], show: "l →", label: "ペインを右と入れ替え", stay: true, run: swap("right") },
    ],
  },
  scroll: {
    title: "SCROLL",
    leave: "ctrl-s",
    rows: [
      { on: ["k", "up"], show: "k ↑", label: "1 行上", stay: true, run: scroll({ lines: -1 }) },
      { on: ["j", "down"], show: "j ↓", label: "1 行下", stay: true, run: scroll({ lines: 1 }) },
      { on: ["u"], show: "u", label: "半ページ上", stay: true, run: scroll({ pages: -0.5 }) },
      { on: ["d"], show: "d", label: "半ページ下", stay: true, run: scroll({ pages: 0.5 }) },
      { on: ["h", "left", "pageup", "ctrl-b"], show: "h ← ^b", label: "1 ページ上", stay: true, run: scroll({ pages: -1 }) },
      { on: ["l", "right", "pagedown", "ctrl-f"], show: "l → ^f", label: "1 ページ下", stay: true, run: scroll({ pages: 1 }) },
      { on: ["s"], show: "s", label: "検索", run: () => run("terminal.search", {}) },
      { on: ["ctrl-c"], show: "^c", label: "最下部へ戻って終了", run: scroll({ to: "bottom" }) },
    ],
  },
  session: {
    title: "SESSION",
    leave: "ctrl-o",
    rows: [
      { on: ["w"], show: "w", label: "スペース / タブを選ぶ", run: () => run("mod.open", { name: "picker" }) },
      { on: ["c"], show: "c", label: "設定", run: () => run("app.settings", {}) },
    ],
  },
};

export function modeView(name) {
  const mode = MODES[name];
  return class ZjMode extends View {
    init(_props, cx) {
      // 開いた時点でキーボードを持っていたペイン。以後このオーバーレイがキーボードを持つ。
      this.at = focused();
      this.handle = cx.focus_handle();
      this.handle.focus();
      cx.timer.after(60, () => this.handle.focus());
    }

    close() {
      closeOverlay(props().overlay);
    }

    key(e, cx) {
      const k = e.keystroke;
      if (k === "escape" || k === "enter") {
        cx.stop_propagation();
        return this.close();
      }
      const row = mode.rows.find((r) => r.on.includes(k));
      if (!row) return;
      cx.stop_propagation();
      if (!row.stay) this.close();
      row.run(this.at, k);
    }

    render() {
      const t = theme();
      return v_flex()
        .id(`zj-${name}`)
        .track_focus(this.handle)
        .on_key_down((e, cx) => this.key(e, cx))
        .w_full()
        .p(14)
        .gap(3)
        .bg(t.popover)
        .text_size(12.5)
        .child(
          h_flex().pb(7).items_center().justify_between()
            .child(div().px(7).py(2).rounded(5).bg(t.accent).text_color(t.accent_foreground).text_size(11).font_semibold().child(mode.title))
            .child(div().text_size(11).text_color(t.dim).child(`Esc / Enter / ${mode.leave} で戻る`)),
        )
        .children(
          mode.rows.map((r) =>
            h_flex().h(22).gap(10).items_center()
              .child(div().w(64).text_color(t.accent).font_semibold().child(r.show))
              .child(div().flex_1().text_color(t.foreground).child(r.label))
              .when(Boolean(r.stay), (el) => el.child(div().text_size(10.5).text_color(t.dim).child("連続"))),
          ),
        );
    }
  };
}
