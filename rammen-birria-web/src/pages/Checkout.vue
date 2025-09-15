<script setup lang="ts">
import { ref, watch, computed } from "vue";
import { useRouter } from "vue-router";
import { useCart } from "@/composables/useCart";
import { createOrder, previewOrder, type OrderPreview, type NewOrderItem } from "@/api/orders";

const router = useRouter();
const { items, total: cartTotal, setQty, remove, clear } = useCart();

const customer_name = ref("");
const customer_phone = ref("");
const customer_address = ref("");
const delivery_method = ref<"pickup"|"delivery">("pickup");
const payment_method  = ref<"cash"|"card"|"transfer">("cash");

const loading = ref(false);
const error = ref("");
const successCode = ref<string | null>(null);

const preview = ref<OrderPreview | null>(null);
const previewMap = computed(() => {
  const m = new Map<number, OrderPreview["items"][number]>();
  (preview.value?.items ?? []).forEach(i => m.set(i.product_id, i));
  return m;
});
const previewTotal = computed(() => preview.value?.total ?? cartTotal.value);

const cartPayload = computed<NewOrderItem[]>(() =>
  items.value.map(i => ({ product_id: i.product_id, quantity: i.qty }))
);

async function loadPreview() {
  if (!items.value.length) { preview.value = { items: [], total: 0 }; return; }
  try {
    preview.value = await previewOrder(cartPayload.value);
  } catch {
    preview.value = null;
  }
}
watch(items, loadPreview, { deep: true, immediate: true });

async function submit() {
  error.value = ""; successCode.value = null;
  if (!items.value.length) { error.value = "Tu carrito está vacío."; return; }
  if (!customer_name.value || !customer_phone.value) { error.value = "Nombre y teléfono son obligatorios."; return; }

  loading.value = true;
  try {
    const order = await createOrder({
      customer_name: customer_name.value,
      customer_phone: customer_phone.value,
      customer_address: customer_address.value,
      delivery_method: delivery_method.value,
      payment_method: payment_method.value,
      items: cartPayload.value,
    });
    successCode.value = order.code;
    clear();
  } catch (e:any) {
    error.value = e?.response?.data?.error || e?.message || "No se pudo crear el pedido.";
  } finally {
    loading.value = false;
  }
}
</script>

<template>
  <div class="max-w-4xl mx-auto p-4 md:p-6">
    <h1 class="text-2xl font-bold mb-4">Finalizar pedido</h1>

    <div class="grid md:grid-cols-3 gap-6">
      <div class="md:col-span-2 bg-white border rounded-xl p-4 space-y-3">
        <div v-for="it in items" :key="it.product_id" class="flex items-center justify-between gap-3 border-b pb-3">
          <div>
            <div class="font-medium">{{ it.name }}</div>

            <div class="text-xs text-gray-500">
              <template v-if="previewMap.get(it.product_id)?.discount_percent">
                <span class="line-through mr-1">${{ it.price.toLocaleString() }}</span>
                <span class="text-indigo-700 font-medium">
                  ${{ previewMap.get(it.product_id)?.unit_price.toLocaleString() }} c/u
                </span>
                <span class="ml-1 text-[11px] bg-indigo-50 text-indigo-700 px-1.5 py-0.5 rounded">
                  -{{ previewMap.get(it.product_id)?.discount_percent }}%
                </span>
              </template>
              <template v-else>
                ${{ it.price.toLocaleString() }} c/u
              </template>
            </div>
          </div>

          <div class="flex items-center gap-2">
            <input type="number" min="1" class="w-20 border rounded px-2 py-1"
                   :value="it.qty" @input="setQty(it.product_id, Number(($event.target as HTMLInputElement).value))">
            <button class="text-red-600 text-sm border rounded px-2 py-1" @click="remove(it.product_id)">Quitar</button>
          </div>
        </div>

        <div v-if="!items.length" class="text-sm text-gray-500">Tu carrito está vacío.</div>
      </div>

      <div class="bg-white border rounded-xl p-4 space-y-3">
        <div class="font-semibold">Datos del cliente</div>

        <label class="block text-sm">Nombre
          <input v-model="customer_name" type="text" class="w-full border rounded px-3 py-2 mt-1"/>
        </label>

        <label class="block text-sm">Teléfono
          <input v-model="customer_phone" type="text" class="w-full border rounded px-3 py-2 mt-1"/>
        </label>

        <label class="block text-sm">Dirección (si entrega)
          <input v-model="customer_address" type="text" class="w-full border rounded px-3 py-2 mt-1"/>
        </label>

        <div class="grid grid-cols-2 gap-3">
          <label class="block text-sm">Entrega
            <select v-model="delivery_method" class="w-full border rounded px-3 py-2 mt-1">
              <option value="pickup">Retiro en local</option>
              <option value="delivery">Domicilio</option>
            </select>
          </label>
          <label class="block text-sm">Pago
            <select v-model="payment_method" class="w-full border rounded px-3 py-2 mt-1">
              <option value="cash">Efectivo</option>
              <option value="card">Tarjeta</option>
              <option value="transfer">Transferencia</option>
            </select>
          </label>
        </div>

        <div class="flex items-center justify-between mt-2">
          <div class="font-semibold">Total</div>
          <div class="text-indigo-700 font-bold">
            ${{ previewTotal.toLocaleString() }}
          </div>
        </div>

        <div v-if="error" class="bg-red-50 text-red-700 rounded px-3 py-2 text-sm">{{ error }}</div>
        <div v-if="successCode" class="bg-green-50 text-green-700 rounded px-3 py-2 text-sm">
          ¡Pedido creado! Código: <span class="font-semibold">{{ successCode }}</span>
        </div>

        <button :disabled="loading || !items.length"
                class="w-full bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg px-4 py-2 disabled:opacity-50"
                @click="submit">
          {{ loading ? "Enviando..." : "Confirmar pedido" }}
        </button>

        <button class="w-full border rounded-lg px-4 py-2 mt-2" @click="router.push({ name: 'products-index' })">
          Seguir comprando
        </button>
      </div>
    </div>
  </div>
</template>
