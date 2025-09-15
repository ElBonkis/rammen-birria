import http from "./http";

export async function login(email: string, password: string): Promise<string> {
  const { data } = await http.post<{ access_token: string }>("/auth/login", { email, password });
  return data.access_token;
}

export async function logout(): Promise<void> {
  await http.delete("/auth/logout").catch(() => {  });
}
