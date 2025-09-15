import http from "./http";
import { directUpload } from "./uploads";

export type Product = {
  id: number;
  name: string;
  price: number;
  description: string | null;
  available: boolean;
  image_url?: string | null;
  created_at?: string;
  updated_at?: string;
  discount_percent?: number;
  price_with_discount?: number; 
  categories?: { id: number; name: string }[];
};

type ProductInput = {
  name: string;
  price: number;
  description?: string;
  available: boolean;
  file?: File | null;
  category_ids?: number[];
};

type ListFilters = {
  category_id?: number | null;
  search?: string | null;
};

export async function getProducts(filters: ListFilters = {}): Promise<Product[]> {
  const params: Record<string, any> = {};
  if (filters.category_id) params.category_id = Number(filters.category_id);
  if (filters.search) params.search = String(filters.search);

  const { data } = await http.get<Product[]>("/products.json", { params });
  return data;
}

export async function getProduct(id: number): Promise<Product> {
  const { data } = await http.get<Product>(`/products/${id}.json`);
  return data;
}

export async function createProduct(input: ProductInput): Promise<Product> {
  let image_signed_id: string | undefined;
  if (input.file) image_signed_id = await directUpload(input.file);

  const payload: any = {
    product: {
      name: input.name.trim(),
      price: Number(input.price),
      description: input.description ?? "",
      available: Boolean(input.available),
      category_ids: (input.category_ids ?? []).map(Number),
    },
  };
  if (image_signed_id) payload.image_signed_id = image_signed_id;

  const { data } = await http.post<Product>("/products.json", payload);
  return data;
}

export async function updateProduct(id: number, input: ProductInput): Promise<Product> {
  let image_signed_id: string | undefined;
  if (input.file) image_signed_id = await directUpload(input.file);

  const payload: any = {
    product: {
      name: input.name.trim(),
      price: Number(input.price),
      description: input.description ?? "",
      available: Boolean(input.available),
      category_ids: (input.category_ids ?? []).map(Number),
    },
  };
  if (image_signed_id) payload.image_signed_id = image_signed_id;

  const { data } = await http.patch<Product>(`/products/${id}.json`, payload);
  return data;
}

export async function deleteProduct(id: number): Promise<void> {
  await http.delete(`/products/${id}.json`);
}
