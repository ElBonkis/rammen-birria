import { ref, computed, watch } from "vue";
import type { Product } from "@/api/products";

export type CartItem = { product_id: number; name: string; price: number; qty: number };

const KEY = "cart:v1";
const items = ref<CartItem[]>(JSON.parse(localStorage.getItem(KEY) || "[]"));

watch(items, v => localStorage.setItem(KEY, JSON.stringify(v)), { deep: true });

export function useCart() {
  function add(p: Product, qty = 1) {
    const i = items.value.findIndex(x => x.product_id === p.id);
    if (i >= 0) items.value[i].qty += qty;
    else items.value.push({ product_id: p.id, name: p.name, price: Number(p.price), qty });
  }
  function remove(id: number) {
    items.value = items.value.filter(x => x.product_id !== id);
  }
  function clear() { items.value = []; }
  function setQty(id: number, qty: number) {
    const it = items.value.find(x => x.product_id === id);
    if (it) it.qty = Math.max(1, qty);
  }
  const count = computed(() => items.value.reduce((a, b) => a + b.qty, 0));
  const total = computed(() => items.value.reduce((a, b) => a + b.qty * b.price, 0));
  return { items, add, remove, clear, setQty, count, total };
}
