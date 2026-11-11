// cmd-j (keys.json) で開き、見てほしいエージェントへ飛んですぐ閉じる。
// 優先順: blocked(入力待ち)> done(見ていない間に終わった)。同じ優先度の中では
// 今いるエージェントの次へ回るので、押すたびに順番に巡回する。
import { View, div } from "gpui-kit";
import { agents, run, props, closeOverlay, notify } from "herdr";

const RANK = { blocked: 0, done: 1 };

function target() {
  const all = agents();
  const waiting = all.filter((a) => a.status in RANK);
  if (waiting.length === 0) return null;
  const best = Math.min(...waiting.map((a) => RANK[a.status]));
  const group = waiting.filter((a) => RANK[a.status] === best);
  const here = group.findIndex((a) => a.focused);
  return group[(here + 1) % group.length];
}

// 「いない」ときに今の内訳を見せる。0 件なら Herdr がエージェントとして認識していない。
const LABEL = { working: "作業中", idle: "待機", blocked: "入力待ち", done: "完了" };
function summary() {
  const all = agents();
  if (all.length === 0) return "エージェントとして認識されている端末が 0 件です";
  const count = {};
  for (const a of all) count[a.status] = (count[a.status] ?? 0) + 1;
  return Object.entries(count).map(([s, n]) => `${LABEL[s] ?? s} ${n}`).join(" / ");
}

export default class JumpAttention extends View {
  init(_props, cx) {
    cx.timer.after(0, () => {
      const a = target();
      closeOverlay(props().overlay);
      if (a) run("pane.focus", { pane: a.pane });
      else notify({ title: summary(), body: "入力待ち・未確認の完了はありません", level: "info", timeout: 3000 });
    });
  }

  render() {
    return div();
  }
}
