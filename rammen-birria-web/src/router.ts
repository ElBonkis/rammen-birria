import { createRouter, createWebHistory } from "vue-router";
import Login from "@/pages/Login.vue";
import Register from "@/pages/Register.vue";
import Dashboard from "@/pages/Dashboard.vue";
import ForgotPassword from "@/pages/ForgotPassword.vue";
import ResetPassword from "@/pages/ResetPassword.vue";
import ProductForm from "@/pages/ProductForm.vue";
import ProductsIndex from "@/pages/ProductsIndex.vue";
import CategoriesIndex from "@/pages/CategoriesIndex.vue";
import CategoryForm from "@/pages/CategoryForm.vue";
import Checkout from "@/pages/Checkout.vue";
import OrdersAdmin from "@/pages/OrdersAdmin.vue";
import { useAuth } from "@/stores/auth";

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior() {
    return { top: 0, left: 0 };
  },
  routes: [
    // Público
    { path: "/", redirect: "/products" },
    { path: "/products", name: "products-index", component: ProductsIndex }, // catálogo público
    { path: "/checkout", name: "checkout", component: Checkout },

    { path: "/login", name: "login", component: Login, meta: { guestOnly: true } },
    { path: "/register", name: "register", component: Register, meta: { guestOnly: true } },
    { path: "/forgot-password", name: "forgot-password", component: ForgotPassword, meta: { guestOnly: true } },
    { path: "/reset-password", name: "reset-password", component: ResetPassword, meta: { guestOnly: true } },

    { path: "/dashboard", name: "dashboard", component: Dashboard, meta: { requiresAuth: true } },

    { path: "/products/new", name: "products-new", component: ProductForm, meta: { requiresAuth: true } },
    { path: "/products/:id/edit", name: "products-edit", component: ProductForm, meta: { requiresAuth: true } },

    { path: "/categories", name: "categories-index", component: CategoriesIndex, meta: { requiresAuth: true } },
    { path: "/categories/new", name: "categories-new", component: CategoryForm, meta: { requiresAuth: true } },
    { path: "/categories/:id/edit", name: "categories-edit", component: CategoryForm, meta: { requiresAuth: true } },

    { path: "/orders", name: "orders-admin", component: OrdersAdmin, meta: { requiresAuth: true } },

    { path: "/:pathMatch(.*)*", redirect: "/products" },
  ],
});

router.beforeEach(async (to) => {
  const auth = useAuth();
  const isAuth = !!auth.token;

  if (to.meta.requiresAuth && !isAuth) {
    try {
      await auth.refresh();
    } catch {
      return { name: "login", query: { redirect: to.fullPath } };
    }
  }

  if (to.meta.guestOnly && isAuth) {
    const next = (to.query.redirect as string) || "/dashboard";
    return next;
  }

  return true;
});

export default router;