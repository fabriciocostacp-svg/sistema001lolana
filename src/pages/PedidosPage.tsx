import { useState, useRef, useMemo } from "react";
import DOMPurify from "dompurify";
import jsPDF from "jspdf";
import { MainLayout } from "@/components/layout/MainLayout";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { usePedidos, PedidoDB } from "@/hooks/usePedidos";
import { StatusPedido } from "@/types";
import {
  ClipboardList,
  MessageCircle,
  WashingMachine,
  Shirt,
  Check,
  X,
  Loader2,
  Trash2,
  Printer,
  DollarSign,
  Download,
  Send,
  FileText,
  FileDown,
} from "lucide-react";
import { toast } from "sonner";
import { CupomImpressao } from "@/components/CupomImpressao";
import lolanaLogo from "@/assets/lolana.png";

const ENDERECO_LOLANA = "Rua Cinco n°752 Vila Garbi (esquina com Av. 6)";

const statusConfig: Record<
  StatusPedido,
  { label: string; icon: React.ElementType; bgClass: string; textClass: string }
> = {
  lavando: {
    label: "Lavando",
    icon: WashingMachine,
    bgClass: "bg-[hsl(210,100%,50%)]",
    textClass: "text-white",
  },
  passando: {
    label: "Passando",
    icon: Shirt,
    bgClass: "bg-[hsl(38,92%,50%)]",
    textClass: "text-white",
  },
  pronto: {
    label: "Pronto",
    icon: Check,
    bgClass: "bg-[hsl(142,76%,36%)]",
    textClass: "text-white",
  },
};

export const PedidosPage = () => {
  const {
    pedidos,
    isLoading,
    updatePedidoStatus,
    updatePedidoPagamento,
    deletePedido,
  } = usePedidos();
  const [printDialog, setPrintDialog] = useState<{
    open: boolean;
    pedido: PedidoDB | null;
  }>({ open: false, pedido: null });
  const [printCpfCnpj, setPrintCpfCnpj] = useState("");
  const cupomRef = useRef<HTMLDivElement>(null);

  const [filterStatus, setFilterStatus] = useState<"todos" | StatusPedido>(
    "todos",
  );
  const [filterDataInicio, setFilterDataInicio] = useState("");
  const [filterDataFim, setFilterDataFim] = useState("");

  const pedidosFiltrados = useMemo(() => {
    return pedidos.filter((p) => {
      if (filterStatus !== "todos" && p.status !== filterStatus) return false;
      if (filterDataInicio) {
        const pedidoDate = new Date(p.created_at).toISOString().slice(0, 10);
        if (pedidoDate < filterDataInicio) return false;
      }
      if (filterDataFim) {
        const pedidoDate = new Date(p.created_at).toISOString().slice(0, 10);
        if (pedidoDate > filterDataFim) return false;
      }
      return true;
    });
  }, [pedidos, filterStatus, filterDataInicio, filterDataFim]);

  const exportarCSV = () => {
    const headers = [
      "Pedido",
      "Cliente",
      "Telefone",
      "Itens",
      "Valor Total",
      "Status",
      "Pago",
      "Data",
    ];
    const rows = pedidosFiltrados.map((p) => [
      `#${p.numero}`,
      p.cliente_nome,
      p.cliente_telefone,
      p.itens.map((i) => `${i.quantidade}x ${i.servico.nome}`).join("; "),
      formatCurrency(p.valor_total),
      statusConfig[p.status].label,
      p.pago ? "Sim" : "Não",
      new Date(p.created_at).toLocaleDateString("pt-BR"),
    ]);
    const csvContent = [headers, ...rows]
      .map((row) =>
        row.map((cell) => `"${String(cell).replace(/"/g, '""')}"`).join(","),
      )
      .join("\n");
    const blob = new Blob(["\uFEFF" + csvContent], {
      type: "text/csv;charset=utf-8;",
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `pedidos_lolana_${new Date().toISOString().slice(0, 10)}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  };

  const formatCurrency = (value: number) => {
    return value.toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
    });
  };

  const handleStatusChange = (pedido: PedidoDB, newStatus: StatusPedido) => {
    updatePedidoStatus.mutate({ id: pedido.id, status: newStatus });

    if (newStatus === "pronto") {
      const mensagem = `Olá ${pedido.cliente_nome}! 😊\n\nSeu pedido da Lolana Lavanderia está pronto para retirada.\nValor total: ${formatCurrency(pedido.valor_total)}.\n\nAguardamos você!\n\n📞 Contato: (19) 99757-9086`;
      const telefone = pedido.cliente_telefone.replace(/\D/g, "");
      const whatsappUrl = `https://wa.me/55${telefone}?text=${encodeURIComponent(mensagem)}`;
      window.open(whatsappUrl, "_blank");
      toast.success("Mensagem de WhatsApp preparada!");
    }
  };

  const handleMarcarRetiradoPago = (pedido: PedidoDB) => {
    updatePedidoPagamento.mutate({ id: pedido.id, pago: true, retirado: true });
    toast.success("Pedido marcado como retirado e pago!");
  };

  const handleMarcarRetiradoNaoPago = (pedido: PedidoDB) => {
    updatePedidoPagamento.mutate({
      id: pedido.id,
      pago: false,
      retirado: true,
    });
    toast.warning("Pedido marcado como retirado SEM pagamento!");
  };

  const handleMarcarComoPago = (pedido: PedidoDB) => {
    updatePedidoPagamento.mutate({
      id: pedido.id,
      pago: true,
      retirado: pedido.retirado,
    });
    toast.success("Pedido marcado como PAGO!");
  };

  const handleOpenPrint = (pedido: PedidoDB) => {
    setPrintCpfCnpj(pedido.cliente_cpf || pedido.cliente_cnpj || "");
    setPrintDialog({ open: true, pedido });
  };

  const handleEnviarWhatsAppCupom = () => {
    const pedido = printDialog.pedido;
    if (!pedido) return;
    const mensagem = gerarTextoCupom(pedido, false, true);
    const telefone = pedido.cliente_telefone.replace(/\D/g, "");
    window.open(
      `https://wa.me/55${telefone}?text=${encodeURIComponent(mensagem)}`,
      "_blank",
    );
    setPrintDialog({ open: false, pedido: null });
  };

  const gerarTextoCupom = (
    pedido: PedidoDB,
    comEmojis = false,
    incluirLogoNaMensagem = false,
  ) => {
    const itens = pedido.itens
      .map(
        (i) =>
          `  - ${i.quantidade}x ${i.servico.nome} - ${formatCurrency(i.servico.preco * i.quantidade)}`,
      )
      .join("\n");
    const desconto = Number(pedido.desconto_percentual) || 0;
    const descontoValor = Number(pedido.desconto_valor) || 0;
    const taxaEntrega = Number(pedido.taxa_entrega) || 0;
    const subtotal = pedido.itens.reduce(
      (acc, i) => acc + i.servico.preco * i.quantidade,
      0,
    );
    const prefixo = comEmojis
      ? {
          loja: "🧺 ",
          pedido: "📋 ",
          cliente: "👤 ",
          doc: "📄 ",
          subtotal: "🏷️ ",
          desconto: "🏷️ ",
          entrega: "🚚 ",
          total: "💰 ",
        }
      : {
          loja: "",
          pedido: "",
          cliente: "",
          doc: "",
          subtotal: "",
          desconto: "",
          entrega: "",
          total: "",
        };

    const logoUrl = new URL(lolanaLogo, window.location.origin).toString();
    let texto = `${prefixo.loja}LOLANA LAVANDERIA\n`;
    if (incluirLogoNaMensagem) texto += `${logoUrl}\n`;
    texto += `Endereço da Lavanderia: ${ENDERECO_LOLANA}\n`;
    texto += `--------------------------------\n`;
    texto += `${prefixo.pedido}Pedido #${pedido.numero}\n\n`;
    texto += `${prefixo.cliente}Cliente: ${pedido.cliente_nome}\n`;
    texto += `Telefone: ${pedido.cliente_telefone}\n`;
    if (printCpfCnpj) texto += `${prefixo.doc}CPF/CNPJ: ${printCpfCnpj}\n`;
    texto += `Data: ${formatDate(pedido.created_at)}\n\n`;
    texto += `Itens:\n${itens}\n\n`;

    if (desconto > 0) {
      texto += `${prefixo.subtotal}Subtotal: ${formatCurrency(subtotal)}\n`;
      texto += `${prefixo.desconto}Desconto (${desconto}%): -${formatCurrency((subtotal * desconto) / 100)}\n`;
    }
    if (descontoValor > 0)
      texto += `${prefixo.desconto}Desconto: -${formatCurrency(descontoValor)}\n`;
    if (taxaEntrega > 0)
      texto += `${prefixo.entrega}Entrega: +${formatCurrency(taxaEntrega)}\n`;

    texto += `--------------------------------\n`;
    texto += `${prefixo.total}Total: ${formatCurrency(pedido.valor_total)}\n\n`;
    texto += `Contato: (19) 99757-9086\n`;
    texto += `Obrigado pela preferencia!`;
    return texto;
  };

  const handleBaixarTxtCupom = () => {
    const pedido = printDialog.pedido;
    if (!pedido) return;
    const texto = gerarTextoCupom(pedido);
    const blob = new Blob([texto], { type: "text/plain;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `cupom_pedido_${pedido.numero}.txt`;
    link.click();
    URL.revokeObjectURL(url);
    toast.success("Arquivo TXT baixado!");
  };

  const handleBaixarPdfCupom = () => {
    const pedido = printDialog.pedido;
    if (!pedido) return;
    const gerarPdf = async () => {
      const doc = new jsPDF({ unit: "pt", format: "a4" });
      doc.setFont("courier", "normal");
      doc.setFontSize(10);

      const carregarLogoDataUrl = async () => {
        const response = await fetch(lolanaLogo);
        const blob = await response.blob();
        return await new Promise<string>((resolve) => {
          const reader = new FileReader();
          reader.onload = () => resolve(String(reader.result));
          reader.readAsDataURL(blob);
        });
      };

      try {
        const logoDataUrl = await carregarLogoDataUrl();
        doc.addImage(logoDataUrl, "PNG", 40, 30, 44, 44);
      } catch {
        // Se falhar a logo, o PDF ainda e gerado com os dados do cupom.
      }

      const texto = gerarTextoCupom(pedido);
      const linhas = doc.splitTextToSize(texto, 515);
      doc.text(linhas, 40, 90);
      doc.save(`cupom_pedido_${pedido.numero}.pdf`);
      toast.success("Arquivo PDF baixado!");
    };

    void gerarPdf();
  };

  const handlePrint = () => {
    if (cupomRef.current) {
      // SECURITY: Sanitize HTML content before writing to print window
      const rawContent = cupomRef.current.innerHTML;
      const sanitizedContent = DOMPurify.sanitize(rawContent, {
        ALLOWED_TAGS: [
          "div",
          "span",
          "p",
          "h1",
          "h2",
          "h3",
          "img",
          "table",
          "tr",
          "td",
          "th",
          "tbody",
          "thead",
          "strong",
          "em",
          "br",
        ],
        ALLOWED_ATTR: ["class", "style", "src", "alt"],
      });

      const printWindow = window.open("", "_blank");
      if (printWindow) {
        printWindow.document.write(`
          <html>
            <head>
              <title>Cupom - Lolana Lavanderia</title>
              <style>
                body { font-family: monospace; font-size: 12px; margin: 0; padding: 20px; }
                * { box-sizing: border-box; }
              </style>
            </head>
            <body>${sanitizedContent}</body>
          </html>
        `);
        printWindow.document.close();
        printWindow.print();
      }
    }
    setPrintDialog({ open: false, pedido: null });
  };

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  if (isLoading) {
    return (
      <MainLayout title="Pedidos">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout title="Pedidos">
      <Card className="shadow-xl border-0 rounded-2xl overflow-hidden">
        <CardHeader className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 bg-gradient-to-r from-[hsl(210,100%,50%)] to-[hsl(215,70%,35%)] text-white rounded-t-2xl">
          <div className="flex items-center gap-3">
            <ClipboardList className="h-5 w-5 md:h-6 md:w-6" />
            <CardTitle className="text-white text-lg md:text-xl">
              Gerenciamento de Pedidos
            </CardTitle>
          </div>
          <Badge className="bg-white/20 text-white border-0">
            {pedidos.length} pedido(s)
          </Badge>
        </CardHeader>
        <CardContent className="p-0">
          {/* Filtros */}
          <div className="p-4 border-b bg-muted/30 flex flex-wrap gap-3 items-end">
            <div className="flex flex-col gap-1">
              <Label className="text-xs text-muted-foreground">Status</Label>
              <Select
                value={filterStatus}
                onValueChange={(v) =>
                  setFilterStatus(v as "todos" | StatusPedido)
                }
              >
                <SelectTrigger className="w-36 rounded-xl h-9 text-sm">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent className="rounded-xl">
                  <SelectItem value="todos">Todos</SelectItem>
                  <SelectItem value="lavando">Lavando</SelectItem>
                  <SelectItem value="passando">Passando</SelectItem>
                  <SelectItem value="pronto">Pronto</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="flex flex-col gap-1">
              <Label className="text-xs text-muted-foreground">De</Label>
              <Input
                type="date"
                value={filterDataInicio}
                onChange={(e) => setFilterDataInicio(e.target.value)}
                className="w-36 rounded-xl h-9 text-sm"
              />
            </div>
            <div className="flex flex-col gap-1">
              <Label className="text-xs text-muted-foreground">Até</Label>
              <Input
                type="date"
                value={filterDataFim}
                onChange={(e) => setFilterDataFim(e.target.value)}
                className="w-36 rounded-xl h-9 text-sm"
              />
            </div>
            {(filterStatus !== "todos" ||
              filterDataInicio ||
              filterDataFim) && (
              <Button
                variant="ghost"
                size="sm"
                onClick={() => {
                  setFilterStatus("todos");
                  setFilterDataInicio("");
                  setFilterDataFim("");
                }}
                className="h-9 rounded-xl text-xs self-end"
              >
                Limpar filtros
              </Button>
            )}
          </div>
          {pedidos.length === 0 ? (
            <div className="p-8 md:p-12 text-center text-muted-foreground">
              <ClipboardList className="h-12 w-12 md:h-16 md:w-16 mx-auto mb-4 opacity-30" />
              <p className="text-base md:text-lg">Nenhum pedido criado</p>
              <p className="text-sm">Crie pedidos na aba "Serviços"</p>
            </div>
          ) : pedidosFiltrados.length === 0 ? (
            <div className="p-8 md:p-12 text-center text-muted-foreground">
              <ClipboardList className="h-12 w-12 md:h-16 md:w-16 mx-auto mb-4 opacity-30" />
              <p className="text-base md:text-lg">Nenhum pedido encontrado</p>
              <p className="text-sm">Tente ajustar os filtros</p>
            </div>
          ) : (
            <>
              {/* Mobile Cards View */}
              <div className="block lg:hidden divide-y">
                {pedidosFiltrados.map((pedido) => {
                  const StatusIcon = statusConfig[pedido.status].icon;
                  const isPronto = pedido.status === "pronto";

                  return (
                    <div key={pedido.id} className="p-4 space-y-3">
                      <div className="flex items-start justify-between gap-2">
                        <div>
                          <span className="font-mono font-bold text-[hsl(210,100%,50%)]">
                            #{pedido.numero}
                          </span>
                          <p className="font-medium">{pedido.cliente_nome}</p>
                          <p className="text-sm text-muted-foreground">
                            {pedido.cliente_telefone}
                          </p>
                        </div>
                        <div className="text-right">
                          <p className="font-mono font-bold text-lg text-[hsl(215,70%,25%)]">
                            {formatCurrency(pedido.valor_total)}
                          </p>
                          <p className="text-xs text-muted-foreground">
                            {formatDate(pedido.created_at)}
                          </p>
                        </div>
                      </div>

                      <div className="text-sm text-muted-foreground bg-muted/50 rounded-lg p-2">
                        {pedido.itens.map((item, i) => (
                          <span key={i}>
                            {item.quantidade}x {item.servico.nome}
                            {i < pedido.itens.length - 1 ? ", " : ""}
                          </span>
                        ))}
                      </div>

                      <div className="flex flex-wrap items-center gap-2">
                        <Select
                          value={pedido.status}
                          onValueChange={(value: StatusPedido) =>
                            handleStatusChange(pedido, value)
                          }
                        >
                          <SelectTrigger
                            className={`${statusConfig[pedido.status].bgClass} ${statusConfig[pedido.status].textClass} border-0 rounded-xl w-auto min-w-[130px]`}
                          >
                            <div className="flex items-center gap-2">
                              <StatusIcon className="h-4 w-4" />
                              <span className="font-medium">
                                {statusConfig[pedido.status].label}
                              </span>
                            </div>
                          </SelectTrigger>
                          <SelectContent className="rounded-xl">
                            {Object.entries(statusConfig).map(
                              ([key, config]) => {
                                const Icon = config.icon;
                                return (
                                  <SelectItem key={key} value={key}>
                                    <div className="flex items-center gap-2">
                                      <Icon className="h-4 w-4" />
                                      <span>{config.label}</span>
                                    </div>
                                  </SelectItem>
                                );
                              },
                            )}
                          </SelectContent>
                        </Select>

                        {pedido.retirado ? (
                          pedido.pago ? (
                            <Badge className="bg-[hsl(142,76%,36%)]/10 text-[hsl(142,76%,36%)] border-0">
                              <Check className="h-3 w-3 mr-1" />
                              Pago
                            </Badge>
                          ) : (
                            <div className="flex items-center gap-1">
                              <Badge className="bg-destructive/10 text-destructive border-0">
                                <X className="h-3 w-3 mr-1" />
                                Não Pago
                              </Badge>
                              <Button
                                size="sm"
                                onClick={() => handleMarcarComoPago(pedido)}
                                className="bg-[hsl(142,76%,36%)] hover:bg-[hsl(142,76%,30%)] rounded-lg h-7 px-2 text-xs"
                              >
                                <DollarSign className="h-3 w-3 mr-1" />
                                Pagar
                              </Button>
                            </div>
                          )
                        ) : isPronto ? (
                          <div className="flex gap-1">
                            <Button
                              size="sm"
                              onClick={() => handleMarcarRetiradoPago(pedido)}
                              className="bg-[hsl(142,76%,36%)] hover:bg-[hsl(142,76%,30%)] rounded-lg h-8 px-2"
                            >
                              <Check className="h-4 w-4" />
                            </Button>
                            <Button
                              size="sm"
                              variant="destructive"
                              onClick={() =>
                                handleMarcarRetiradoNaoPago(pedido)
                              }
                              className="rounded-lg h-8 px-2"
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </div>
                        ) : null}
                      </div>

                      <div className="flex items-center gap-2 pt-2 border-t">
                        <Button
                          variant="outline"
                          size="sm"
                          className="flex-1 gap-2 rounded-xl"
                          onClick={() => {
                            const mensagem = `Olá, ${pedido.cliente_nome}! 😊\n\nSeu pedido #${pedido.numero} da Lolana Lavanderia.\nValor total: ${formatCurrency(pedido.valor_total)}.\n\n📞 Contato: (19) 99757-9086`;
                            const telefone = pedido.cliente_telefone.replace(
                              /\D/g,
                              "",
                            );
                            window.open(
                              `https://wa.me/55${telefone}?text=${encodeURIComponent(mensagem)}`,
                              "_blank",
                            );
                          }}
                        >
                          <MessageCircle className="h-4 w-4" />
                          WhatsApp
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          className="gap-2 rounded-xl"
                          onClick={() => handleOpenPrint(pedido)}
                        >
                          <Printer className="h-4 w-4" />
                        </Button>
                        <AlertDialog>
                          <AlertDialogTrigger asChild>
                            <Button
                              variant="outline"
                              size="sm"
                              className="gap-2 rounded-xl text-destructive hover:text-destructive"
                            >
                              <Trash2 className="h-4 w-4" />
                            </Button>
                          </AlertDialogTrigger>
                          <AlertDialogContent className="rounded-2xl mx-4 max-w-[calc(100vw-2rem)]">
                            <AlertDialogHeader>
                              <AlertDialogTitle>
                                Excluir Pedido
                              </AlertDialogTitle>
                              <AlertDialogDescription>
                                Tem certeza que deseja excluir o pedido #
                                {pedido.numero}? Esta ação não pode ser
                                desfeita.
                              </AlertDialogDescription>
                            </AlertDialogHeader>
                            <AlertDialogFooter className="flex-col sm:flex-row gap-2">
                              <AlertDialogCancel className="rounded-xl">
                                Cancelar
                              </AlertDialogCancel>
                              <AlertDialogAction
                                onClick={() => deletePedido.mutate(pedido.id)}
                                className="bg-destructive hover:bg-destructive/90 rounded-xl"
                              >
                                Excluir
                              </AlertDialogAction>
                            </AlertDialogFooter>
                          </AlertDialogContent>
                        </AlertDialog>
                      </div>
                    </div>
                  );
                })}
              </div>

              {/* Desktop Table View */}
              <div className="hidden lg:block overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow className="bg-[hsl(210,100%,97%)]">
                      <TableHead className="w-24 font-bold text-[hsl(215,70%,25%)]">
                        Pedido
                      </TableHead>
                      <TableHead className="font-bold text-[hsl(215,70%,25%)]">
                        Cliente
                      </TableHead>
                      <TableHead className="font-bold text-[hsl(215,70%,25%)]">
                        Itens
                      </TableHead>
                      <TableHead className="w-32 text-right font-bold text-[hsl(215,70%,25%)]">
                        Valor
                      </TableHead>
                      <TableHead className="w-40 text-center font-bold text-[hsl(215,70%,25%)]">
                        Status
                      </TableHead>
                      <TableHead className="w-40 text-center font-bold text-[hsl(215,70%,25%)]">
                        Pagamento
                      </TableHead>
                      <TableHead className="w-48 font-bold text-[hsl(215,70%,25%)]">
                        Data
                      </TableHead>
                      <TableHead className="w-40 text-center font-bold text-[hsl(215,70%,25%)]">
                        Ações
                      </TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {pedidosFiltrados.map((pedido) => {
                      const StatusIcon = statusConfig[pedido.status].icon;
                      const isPronto = pedido.status === "pronto";

                      return (
                        <TableRow
                          key={pedido.id}
                          className="hover:bg-[hsl(210,100%,98%)]"
                        >
                          <TableCell className="font-mono font-bold text-[hsl(210,100%,50%)]">
                            #{pedido.numero}
                          </TableCell>
                          <TableCell>
                            <div>
                              <p className="font-medium">
                                {pedido.cliente_nome}
                              </p>
                              <p className="text-sm text-muted-foreground">
                                {pedido.cliente_telefone}
                              </p>
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="text-sm max-w-xs">
                              {pedido.itens.map((item, i) => (
                                <span key={i}>
                                  {item.quantidade}x {item.servico.nome}
                                  {i < pedido.itens.length - 1 ? ", " : ""}
                                </span>
                              ))}
                            </div>
                          </TableCell>
                          <TableCell className="text-right font-mono font-bold text-lg text-[hsl(215,70%,25%)]">
                            {formatCurrency(pedido.valor_total)}
                          </TableCell>
                          <TableCell>
                            <Select
                              value={pedido.status}
                              onValueChange={(value: StatusPedido) =>
                                handleStatusChange(pedido, value)
                              }
                            >
                              <SelectTrigger
                                className={`${statusConfig[pedido.status].bgClass} ${statusConfig[pedido.status].textClass} border-0 rounded-xl`}
                              >
                                <div className="flex items-center gap-2">
                                  <StatusIcon className="h-4 w-4" />
                                  <span className="font-medium">
                                    {statusConfig[pedido.status].label}
                                  </span>
                                </div>
                              </SelectTrigger>
                              <SelectContent className="rounded-xl">
                                {Object.entries(statusConfig).map(
                                  ([key, config]) => {
                                    const Icon = config.icon;
                                    return (
                                      <SelectItem key={key} value={key}>
                                        <div className="flex items-center gap-2">
                                          <Icon className="h-4 w-4" />
                                          <span>{config.label}</span>
                                        </div>
                                      </SelectItem>
                                    );
                                  },
                                )}
                              </SelectContent>
                            </Select>
                          </TableCell>
                          <TableCell className="text-center">
                            {pedido.retirado ? (
                              <div className="flex justify-center items-center gap-2">
                                {pedido.pago ? (
                                  <div className="flex items-center gap-1 text-[hsl(142,76%,36%)]">
                                    <Check className="h-6 w-6" />
                                    <span className="text-xs font-medium">
                                      Pago
                                    </span>
                                  </div>
                                ) : (
                                  <>
                                    <div className="flex items-center gap-1 text-destructive">
                                      <X className="h-5 w-5" />
                                      <span className="text-xs font-medium">
                                        Não Pago
                                      </span>
                                    </div>
                                    <Button
                                      size="sm"
                                      onClick={() =>
                                        handleMarcarComoPago(pedido)
                                      }
                                      className="bg-[hsl(142,76%,36%)] hover:bg-[hsl(142,76%,30%)] rounded-lg h-7 px-2 text-xs"
                                    >
                                      <DollarSign className="h-3 w-3" />
                                    </Button>
                                  </>
                                )}
                              </div>
                            ) : isPronto ? (
                              <div className="flex justify-center gap-1">
                                <Button
                                  size="sm"
                                  onClick={() =>
                                    handleMarcarRetiradoPago(pedido)
                                  }
                                  className="bg-[hsl(142,76%,36%)] hover:bg-[hsl(142,76%,30%)] rounded-lg h-8 px-2"
                                  title="Retirado e Pago"
                                >
                                  <Check className="h-4 w-4" />
                                </Button>
                                <Button
                                  size="sm"
                                  variant="destructive"
                                  onClick={() =>
                                    handleMarcarRetiradoNaoPago(pedido)
                                  }
                                  className="rounded-lg h-8 px-2"
                                  title="Retirado Sem Pagar"
                                >
                                  <X className="h-4 w-4" />
                                </Button>
                              </div>
                            ) : (
                              <span className="text-xs text-muted-foreground">
                                -
                              </span>
                            )}
                          </TableCell>
                          <TableCell className="text-sm text-muted-foreground">
                            {formatDate(pedido.created_at)}
                          </TableCell>
                          <TableCell className="text-center">
                            <div className="flex items-center justify-center gap-1">
                              <Button
                                variant="ghost"
                                size="icon"
                                className="hover:bg-[hsl(142,76%,36%)]/20 hover:text-[hsl(142,76%,36%)] rounded-xl"
                                onClick={() => {
                                  const mensagem = `Olá, ${pedido.cliente_nome}! 😊\n\nSeu pedido #${pedido.numero} da Lolana Lavanderia.\nValor total: ${formatCurrency(pedido.valor_total)}.\n\n📞 Contato: (19) 99757-9086`;
                                  const telefone =
                                    pedido.cliente_telefone.replace(/\D/g, "");
                                  window.open(
                                    `https://wa.me/55${telefone}?text=${encodeURIComponent(mensagem)}`,
                                    "_blank",
                                  );
                                }}
                              >
                                <MessageCircle className="h-5 w-5" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="icon"
                                className="hover:bg-[hsl(210,100%,50%)]/20 hover:text-[hsl(210,100%,50%)] rounded-xl"
                                onClick={() => handleOpenPrint(pedido)}
                              >
                                <Printer className="h-5 w-5" />
                              </Button>
                              <AlertDialog>
                                <AlertDialogTrigger asChild>
                                  <Button
                                    variant="ghost"
                                    size="icon"
                                    className="hover:bg-destructive/20 hover:text-destructive rounded-xl"
                                  >
                                    <Trash2 className="h-4 w-4" />
                                  </Button>
                                </AlertDialogTrigger>
                                <AlertDialogContent className="rounded-2xl">
                                  <AlertDialogHeader>
                                    <AlertDialogTitle>
                                      Excluir Pedido
                                    </AlertDialogTitle>
                                    <AlertDialogDescription>
                                      Tem certeza que deseja excluir o pedido #
                                      {pedido.numero}? Esta ação não pode ser
                                      desfeita.
                                    </AlertDialogDescription>
                                  </AlertDialogHeader>
                                  <AlertDialogFooter>
                                    <AlertDialogCancel className="rounded-xl">
                                      Cancelar
                                    </AlertDialogCancel>
                                    <AlertDialogAction
                                      onClick={() =>
                                        deletePedido.mutate(pedido.id)
                                      }
                                      className="bg-destructive hover:bg-destructive/90 rounded-xl"
                                    >
                                      Excluir
                                    </AlertDialogAction>
                                  </AlertDialogFooter>
                                </AlertDialogContent>
                              </AlertDialog>
                            </div>
                          </TableCell>
                        </TableRow>
                      );
                    })}
                  </TableBody>
                </Table>
              </div>
            </>
          )}
        </CardContent>
      </Card>

      {/* Dialog de Impressão */}
      <Dialog
        open={printDialog.open}
        onOpenChange={(open) =>
          setPrintDialog({ open, pedido: open ? printDialog.pedido : null })
        }
      >
        <DialogContent className="rounded-2xl max-w-md max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>Cupom do Pedido - Escolha a ação</DialogTitle>
          </DialogHeader>
          <div className="space-y-4">
            <div className="space-y-2">
              <Label>CPF/CNPJ (opcional)</Label>
              <Input
                placeholder="Digite CPF ou CNPJ para o cupom"
                value={printCpfCnpj}
                onChange={(e) => setPrintCpfCnpj(e.target.value)}
                className="rounded-xl"
              />
            </div>
            {printDialog.pedido && (
              <div className="border rounded-xl p-2 bg-gray-50 max-h-[400px] overflow-y-auto">
                <CupomImpressao
                  ref={cupomRef}
                  pedido={printDialog.pedido}
                  cpfCnpj={printCpfCnpj}
                />
              </div>
            )}
          </div>
          <DialogFooter className="gap-2 flex-col sm:flex-row">
            <Button
              variant="outline"
              onClick={() => setPrintDialog({ open: false, pedido: null })}
              className="rounded-xl"
            >
              Cancelar
            </Button>
            <Button
              onClick={handleBaixarTxtCupom}
              variant="outline"
              className="rounded-xl gap-2"
            >
              <FileText className="h-4 w-4" />
              Baixar TXT
            </Button>
            <Button
              onClick={handleBaixarPdfCupom}
              variant="outline"
              className="rounded-xl gap-2"
            >
              <FileDown className="h-4 w-4" />
              Baixar PDF
            </Button>
            <Button
              onClick={handleEnviarWhatsAppCupom}
              className="rounded-xl bg-[hsl(142,76%,36%)] hover:bg-[hsl(142,76%,30%)] gap-2"
            >
              <Send className="h-4 w-4" />
              Enviar no WhatsApp
            </Button>
            <Button
              onClick={handlePrint}
              className="rounded-xl bg-gradient-to-r from-[hsl(210,100%,50%)] to-[hsl(215,70%,35%)] gap-2"
            >
              <Printer className="h-4 w-4" />
              Imprimir
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </MainLayout>
  );
};
