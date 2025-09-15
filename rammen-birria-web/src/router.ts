import { createRouter, createWebHistory } from "vue-router";
import Login from "@/pages/Login.vue";
import Register from "@/pages/Register.vue";
import Dashboard from "@/pages/Dashboard.vue";
import ForgotPassword from "@/pages/ForgotPassword.vue";
import ResetPassword from "@/pages/ResetPassword.vue";
import ProductForm from "@/pages/ProductForm.vue";
import ProductsIndex from "@/pages/ProductsIndex.vue";
import CategoriesIndex from "./pages/CategoriesIndex.vue";
import CategoryForm from "./pages/CategoryForm.vue";
import Checkout from "@/pages/Checkout.vue";
import OrdersAdmin from "@/pages/OrdersAdmin.vue";
import { useAuth } from "@/stores/auth";

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: "/", redirect: "/products" },
    { path: "/login", component: Login, meta: { guestOnly: true } },
    { path: "/register", component: Register, meta: { guestOnly: true } },
    { path: "/forgot-password", component: ForgotPassword, meta: { guestOnly: true } },
    { path: "/reset-password", component: ResetPassword, meta: { guestOnly: true } },
    { path: "/dashboard", component: Dashboard, meta: { requiresAuth: true } },

    { path: "/products", name: "products-index", component: ProductsIndex },
    { path: "/products/new", name: "products-new", component: ProductForm, meta: { requiresAuth: true } },
    { path: "/products/:id/edit", name: "products-edit", component: ProductForm, meta: { requiresAuth: true } },

    { path: "/categories", name: "categories-index", component: CategoriesIndex, meta: { requiresAuth: true } },
    { path: "/categories/new", name: "categories-new", component: CategoryForm, meta: { requiresAuth: true } },
    { path: "/categories/:id/edit", name: "categories-edit", component: CategoryForm, meta: { requiresAuth: true } },
    
    { path: "/checkout", name: "checkout", component: Checkout },
    { path: "/orders", name: "orders-admin", component: OrdersAdmin, meta: { requiresAuth: true } },
    { path: "/:pathMatch(.*)*", redirect: "/login" },
  ],
});

router.beforeEach(async (to) => {
  const auth = useAuth();
  if (to.meta.requiresAuth && !auth.token) {
    try { await auth.refresh(); }
    catch { return { path: "/login", query: { redirect: to.fullPath } }; }
  }
  if (to.meta.guestOnly && auth.token) return { path: "/products" };
});

export default router;
