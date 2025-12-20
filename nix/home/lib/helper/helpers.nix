{ lib }:

{
  # Helper for forcibly creating symbolic links
  activation = {
    mkLinkForce = ''
      link_force() {
        local source="$1"
        local target="$2"

        if [ ! -e "$source" ]; then
          echo "Warning: Source does not exist: $source"
          return 1
        fi

        # ターゲットのディレクトリを作成
        $DRY_RUN_CMD mkdir -p "$(dirname "$target")"

        # 既存のシンボリックリンクまたはファイルを削除
        if [ -L "$target" ] || [ -e "$target" ]; then
          echo "Removing existing: $target"
          $DRY_RUN_CMD rm -rf "$target"
        fi

        # 新しいシンボリックリンクを作成
        echo "Linking: $source -> $target"
        $DRY_RUN_CMD ln -sf "$source" "$target"
      }
    '';
  };
}
