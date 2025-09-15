export function apiURL(pathOrUrl?: string | null): string | null {
  if (!pathOrUrl) return null;
  if (/^https?:\/\//i.test(pathOrUrl)) return pathOrUrl;
  if (pathOrUrl.startsWith("/rails/")) return pathOrUrl;
  return `/api${pathOrUrl.startsWith("/") ? "" : "/"}${pathOrUrl}`;
}
