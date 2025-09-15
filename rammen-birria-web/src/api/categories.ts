import http from "./http";

export type Category = {
  id: number;
  name: string;
  description?: string | null;
  discount?: number | null;
  created_at?: string;
  updated_at?: string;
};

export async function fetchCategories(): Promise<Category[]> {
  const { data } = await http.get<Category[]>("/categories.json");
  return data;
}

export async function getCategory(id: number): Promise<Category> {
  const { data } = await http.get<Category>(`/categories/${id}.json`);
  return data;
}

export async function createCategory(input: {
  name: string;
  description?: string;
  discount?: number | null;
}): Promise<Category> {
  const payload = {
    category: {
      name: input.name.trim(),
      description: input.description ?? "",
      discount: input.discount ?? null,
    },
  };
  const { data } = await http.post<Category>("/categories.json", payload);
  return data;
}

export async function updateCategory(
  id: number,
  input: {
    name: string;
    description?: string;
    discount?: number | null;
  }
): Promise<Category> {
  const payload = {
    category: {
      name: input.name.trim(),
      description: input.description ?? "",
      discount: input.discount ?? null,
    },
  };
  const { data } = await http.patch<Category>(`/categories/${id}.json`, payload);
  return data;
}

export async function deleteCategory(id: number): Promise<void> {
  await http.delete(`/categories/${id}.json`);
}
