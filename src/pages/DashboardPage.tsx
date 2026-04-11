import { MainLayout } from "@/components/layout/MainLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { useClientes } from "@/hooks/useClientes";
import { usePedidos } from "@/hooks/usePedidos";
import {
  Users,
  ClipboardList,
  DollarSign,
  WashingMachine,
  Shirt,
  Check,
  Loader2,
} from "lucide-react";

export const DashboardPage = () => {
  const { clientes, isLoading: loadingClientes } = useClientes();
  const { pedidos, isLoading: loadingPedidos } = usePedidos();

  const isLoading = loadingClientes || loadingPedidos;

  const totalClientes = clientes?.length ?? 0;
  const totalPedidos = pedidos?.length ?? 0;

  const pedidosLavando =
    pedidos?.filter((p) => p.status === "lavando").length ?? 0;
  const pedidosPassando =
    pedidos?.filter((p) => p.status === "passando").length ?? 0;
  const pedidosProntos =
    pedidos?.filter((p) => p.status === "pronto").length ?? 0;

  const pedidosPagos = pedidos?.filter((p) => p.pago).length ?? 0;
  const pedidosPendentes = pedidos?.filter((p) => !p.pago).length ?? 0;

  const faturamentoTotal =
    pedidos?.reduce((acc, p) => acc + (p.pago ? p.valor_total : 0), 0) ?? 0;
  const faturamentoPendente =
    pedidos?.reduce((acc, p) => acc + (!p.pago ? p.valor_total : 0), 0) ?? 0;

  const formatCurrency = (value: number) =>
    value.toLocaleString("pt-BR", { style: "currency", currency: "BRL" });

  if (isLoading) {
    return (
      <MainLayout title="Dashboard">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout title="Dashboard">
      <div className="space-y-6">
        {/* Cards principais */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <Card className="border-0 shadow-md">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Total de Clientes
              </CardTitle>
              <div className="p-2 rounded-lg bg-blue-100">
                <Users className="h-5 w-5 text-blue-600" />
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{totalClientes}</p>
              <p className="text-xs text-muted-foreground mt-1">
                cadastrados no sistema
              </p>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-md">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Total de Pedidos
              </CardTitle>
              <div className="p-2 rounded-lg bg-purple-100">
                <ClipboardList className="h-5 w-5 text-purple-600" />
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">{totalPedidos}</p>
              <p className="text-xs text-muted-foreground mt-1">
                {pedidosPagos} pagos · {pedidosPendentes} pendentes
              </p>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-md">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                Faturamento Recebido
              </CardTitle>
              <div className="p-2 rounded-lg bg-green-100">
                <DollarSign className="h-5 w-5 text-green-600" />
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">
                {formatCurrency(faturamentoTotal)}
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                de pedidos pagos
              </p>
            </CardContent>
          </Card>

          <Card className="border-0 shadow-md">
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm font-medium text-muted-foreground">
                A Receber
              </CardTitle>
              <div className="p-2 rounded-lg bg-orange-100">
                <DollarSign className="h-5 w-5 text-orange-500" />
              </div>
            </CardHeader>
            <CardContent>
              <p className="text-3xl font-bold">
                {formatCurrency(faturamentoPendente)}
              </p>
              <p className="text-xs text-muted-foreground mt-1">
                de pedidos pendentes
              </p>
            </CardContent>
          </Card>
        </div>

        {/* Status dos pedidos */}
        <div>
          <h2 className="text-lg font-semibold mb-3">Status dos Pedidos</h2>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <Card className="border-0 shadow-md border-l-4 border-l-blue-500">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                  Lavando
                </CardTitle>
                <WashingMachine className="h-5 w-5 text-blue-500" />
              </CardHeader>
              <CardContent>
                <p className="text-3xl font-bold text-blue-600">
                  {pedidosLavando}
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  pedidos em lavagem
                </p>
              </CardContent>
            </Card>

            <Card className="border-0 shadow-md border-l-4 border-l-yellow-500">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                  Passando
                </CardTitle>
                <Shirt className="h-5 w-5 text-yellow-500" />
              </CardHeader>
              <CardContent>
                <p className="text-3xl font-bold text-yellow-600">
                  {pedidosPassando}
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  pedidos sendo passados
                </p>
              </CardContent>
            </Card>

            <Card className="border-0 shadow-md border-l-4 border-l-green-500">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                  Prontos
                </CardTitle>
                <Check className="h-5 w-5 text-green-500" />
              </CardHeader>
              <CardContent>
                <p className="text-3xl font-bold text-green-600">
                  {pedidosProntos}
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  pedidos prontos para retirada
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};
