<script setup lang="ts">
import { onMounted, ref } from "vue";
import { fetchOrders, updateOrderStatus, type Order } from "@/api/orders";
import AppTopBar from "@/components/AppTopBar.vue";

const orders = ref<Order[]>([]);
const loading = ref(true);
const error = ref("");

const filtro = ref<Order["status"] | "current">("current");

async function load() {
  loading.value = true; error.value = "";
  try {
    const status = filtro.value === "current" ? undefined : filtro.value;
    orders.value = await fetchOrders(status ? { status } : undefined);
  } catch (e:any) {
    error.value = e?.message || "No se pudieron cargar los pedidos.";
  } finally { loading.value = false; }
}

async function setStatus(o: Order, s: Order["status"]) {
  try {
    const upd = await updateOrderStatus(o.id, s);
    const idx = orders.value.findIndex(x => x.id === upd.id);
    if (idx >= 0) orders.value[idx] = upd;
  } catch (e:any) {
    error.value = e?.message || "No se pudo actualizar el estado.";
  }
}

onMounted(load);
</script>

<template>
  <div class="min-h-screen bg-gray-50">
    <AppTopBar />
    <div class="max-w-6xl mx-auto p-4 md:p-6">
      <div class="flex items-center justify-between mb-4">
        <h1 class="text-xl font-bold">Pedidos</h1>
        <select v-model="filtro" @change="load" class="border rounded px-2 py-1">
          <option value="current">Vigentes</option>
          <option value="pending">Pendientes</option>
          <option value="confirmed">Confirmados</option>
          <option value="in_progress">En curso</option>
          <option value="delivered">Entregados</option>
          <option value="cancelled">Cancelados</option>
        </select>
      </div>

      <div v-if="error" class="mb-4 bg-red-50 text-red-700 rounded px-3 py-2 text-sm">{{ error }}</div>
      <div v-if="loading" class="text-sm text-gray-500">Cargando…</div>

      <div v-else class="space-y-3">
        <div v-for="o in orders" :key="o.id" class="bg-white border rounded-xl p-4">
          <div class="flex items-center justify-between">
            <div>
              <div class="font-semibold">#{{ o.code }} • {{ o.customer_name }} ({{ o.customer_phone }})</div>
              <div class="text-xs text-gray-500">
                {{ new Date(o.created_at).toLocaleString() }} • Total ${{ o.total.toLocaleString() }}
              </div>
            </div>
            <div>
              <span class="text-xs px-2 py-1 rounded-full border bg-gray-50">{{ o.status }}</span>
            </div>
          </div>

          <ul class="mt-2 text-sm text-gray-700 list-disc ml-5">
            <li v-for="it in o.items" :key="it.id">{{ it.quantity }} × {{ it.name }} — ${{ it.subtotal.toLocaleString() }}</li>
          </ul>

          <div class="mt-3 flex gap-2">
            <button class="border rounded px-3 py-1 text-sm" @click="setStatus(o,'confirmed')">Confirmar</button>
            <button class="border rounded px-3 py-1 text-sm" @click="setStatus(o,'in_progress')">En curso</button>
            <button class="border rounded px-3 py-1 text-sm" @click="setStatus(o,'delivered')">Entregado</button>
            <button class="border rounded px-3 py-1 text-sm text-red-700 border-red-300" @click="setStatus(o,'cancelled')">Cancelar</button>
          </div>
        </div>

        <div v-if="!orders.length" class="text-sm text-gray-500 text-center py-10">
          No hay pedidos para este filtro.
        </div>
      </div>
    </div>
  </div>
</template>
