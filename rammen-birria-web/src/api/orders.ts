import http from "./http";

export type NewOrderItem = { product_id: number; quantity: number };
export type NewOrderInput = {
  customer_name: string;
  customer_phone: string;
  customer_address?: string;
  delivery_method: "pickup" | "delivery" | 0 | 1;
  payment_method: "cash" | "card" | "transfer" | 0 | 1 | 2;
  items: NewOrderItem[];
};

export type OrderItem = {
  id: number;
  quantity: number;
  price_with_discount: number;
  subtotal: number;
  name: string;
  product: { id: number; name: string; price: number };
};

export type Order = {
  id: number;
  code: string;
  status: "pending" | "confirmed" | "in_progress" | "delivered" | "cancelled";
  customer_name: string;
  customer_phone: string;
  customer_address?: string | null;
  delivery_method: "pickup" | "delivery" | 0 | 1;
  payment_method: "cash" | "card" | "transfer" | 0 | 1 | 2;
  total: number;
  items: OrderItem[];
  created_at: string;
};

export type OrderPreviewItem = {
  product_id: number;
  name: string;
  base_price: number;
  discount_percent: number; 
  unit_price: number;
  quantity: number;
  subtotal: number;
};
export type OrderPreview = { items: OrderPreviewItem[]; total: number };

export async function createOrder(input: NewOrderInput): Promise<Order> {
  const { data } = await http.post("/orders", input);
  return data;
}
export async function fetchOrders(params?: { status?: Order["status"] }): Promise<Order[]> {
  const { data } = await http.get("/orders", { params });
  return data;
}
export async function updateOrderStatus(id: number, status: Order["status"]): Promise<Order> {
  const { data } = await http.patch(`/orders/${id}`, { status });
  return data;
}
export async function previewOrder(items: NewOrderItem[]): Promise<OrderPreview> {
  const { data } = await http.post("/orders/preview", { items });
  return data;
}
