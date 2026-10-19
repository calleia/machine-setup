repo_dir="${1:-.}"
switched=0

# Rewrite every GitHub HTTPS remote (with or without credentials embedded in
# the URL) to its SSH equivalent, leaving any other remote untouched:
for remote in $(git -C "$repo_dir" remote); do
  url=$(git -C "$repo_dir" remote get-url "$remote")
  case "$url" in
    https://github.com/* | https://*@github.com/*)
      path=${url#*github.com/}
      ssh_url="git@github.com:${path%.git}.git"
      git -C "$repo_dir" remote set-url "$remote" "$ssh_url"
      echo "$remote -> $ssh_url"
      switched=1
      ;;
  esac
done

if [ "$switched" -eq 0 ]; then
  echo "No GitHub HTTPS remotes found, nothing to switch."
fi
