"""Builds depictions/<id>.json from src/<id>/depiction.json. Called by index.sh."""
import json, os, sys

repo, url, featured = sys.argv[1], sys.argv[2], sys.argv[3].split()


def screenshots(pkg):
    folder = os.path.join(repo, "assets", "screenshots", pkg)
    names = sorted(os.listdir(folder)) if os.path.isdir(folder) else []
    names = [n for n in names if n.endswith(".png")]
    order = {f"{t}.png": i for i, t in enumerate(featured)}
    names.sort(key=lambda n: (order.get(n, len(order)), n))
    if not names or not url:
        return []
    return [{"class": "DepictionScreenshotsView", "itemCornerRadius": 8, "itemSize": "{300, 220}",
             "screenshots": [{"url": f"{url}/assets/screenshots/{pkg}/{n}", "accessibilityText": f"{n[:-4]}, light and dark"} for n in names]}]


for pkg in sorted(os.listdir(os.path.join(repo, "src"))):
    src = os.path.join(repo, "src", pkg, "depiction.json")
    if not os.path.isfile(src):
        continue
    d = json.loads(open(src).read().replace("{{REPO_URL}}", url))
    for tab in d.get("tabs", []):
        views = []
        for v in tab.get("views", []):
            views += screenshots(pkg) if v.get("class") == "@screenshots" else [v]
        tab["views"] = views
    with open(os.path.join(repo, "depictions", f"{pkg}.json"), "w") as f:
        json.dump(d, f, indent=1)
