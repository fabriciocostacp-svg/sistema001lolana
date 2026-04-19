import { MainLayout } from "@/components/layout/MainLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { useClientes } from "@/hooks/useClientes";
import { usePedidos } from "@/hooks/usePedidos";
import {
  Users,
  ClipboardList,
  DollarSign,
  WashingMachine,
  Shirt,
  Wind,
  Check,
  Loader2,
} from "lucide-react";

export const DashboardPage = () => {
  const {
    clientes,
    isLoading: loadingClientes,
    isError: cliErr,
    error: cliE,
    refetch: refetchCli,
  } = useClientes();
  const {
    pedidos,
    isLoading: loadingPedidos,
    isError: pedErr,
    error: pedE,
    refetch: refetchPed,
  } = usePedidos();

  const isLoading = loadingClientes || loadingPedidos;

  const totalClientes = clientes?.length ?? 0;
  const totalPedidos = pedidos?.length ?? 0;

  const pedidosLavando =
    pedidos?.filter((p) => p.status === "lavando").length ?? 0;
  const pedidosPassando =
    pedidos?.filter((p) => p.status === "passando").length ?? 0;
  const pedidosSecando =
    pedidos?.filter((p) => p.status === "secando").length ?? 0;
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

  if (cliErr || pedErr) {
    return (
      <MainLayout title="Dashboard">
        <Alert variant="destructive" className="max-w-2xl">
          <AlertTitle>Não foi possível carregar o dashboard</AlertTitle>
          <AlertDescription className="space-y-2 text-sm">
            {cliErr && (
              <p>
                Clientes:{" "}
                {cliE instanceof Error ? cliE.message : String(cliE ?? "")}
              </p>
            )}
            {pedErr && (
              <p>
                Pedidos:{" "}
                {pedE instanceof Error ? pedE.message : String(pedE ?? "")}
              </p>
            )}
            <p className="text-muted-foreground">
              Confirme o mesmo projeto no .env (VITE_SUPABASE_URL), deploy da
              função <code className="text-xs">secure-api</code> e sessão de
              login válida.
            </p>
          </AlertDescription>
          <Button
            className="mt-3"
            onClick={() => {
              void refetchCli();
              void refetchPed();
            }}
          >
            Tentar novamente
          </Button>
        </Alert>
      </MainLayout>
    );
  }

  return (
    <MainLayout title="Dashboard">
      <div className="space-y-6">
        {totalPedidos === 0 && totalClientes > 0 && (
          <Alert className="border-amber-200 bg-amber-50 text-amber-950 dark:bg-amber-950/20 dark:text-amber-100 dark:border-amber-800">
            <AlertTitle>Há clientes, mas nenhum pedido na API</AlertTitle>
            <AlertDescription className="text-sm">
              Se no Supabase (SQL opção 5) aparecem pedidos, o app pode estar
              ligado a outro projeto ou a função <code className="text-xs">secure-api</code>{" "}
              não está atualizada. Volte a importar com o ficheiro actual
              (opção 4 do COPIAR-IMPORT.bat) e faça deploy das Edge Functions.
            </AlertDescription>
          </Alert>
        )}
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
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
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

            <Card className="border-0 shadow-md border-l-4 border-l-sky-500">
              <CardHeader className="flex flex-row items-center justify-between pb-2">
                <CardTitle className="text-sm font-medium text-muted-foreground">
                  Secando
                </CardTitle>
                <Wind className="h-5 w-5 text-sky-500" />
              </CardHeader>
              <CardContent>
                <p className="text-3xl font-bold text-sky-600">
                  {pedidosSecando}
                </p>
                <p className="text-xs text-muted-foreground mt-1">
                  pedidos em secagem
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
