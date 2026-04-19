import React, { useState, useMemo, useEffect, useCallback } from "react";
import DOMPurify from "dompurify";
import { MainLayout } from "@/components/layout/MainLayout";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { Badge } from "@/components/ui/badge";
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
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import { useServicos } from "@/hooks/useServicos";
import { useClientes } from "@/hooks/useClientes";
import { usePedidos } from "@/hooks/usePedidos";
import { ItemPedido } from "@/types";
import { Package, ShoppingCart, UserCheck, Loader2, Search, Percent, Truck, FileText, Check, ChevronsUpDown, Scale } from "lucide-react";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { parseLeituraBalanca, formatKgBr } from "@/lib/peso-balanca";
import type { ServicoDB } from "@/hooks/useServicos";

const isKgServico = (s: { categoria: string }) => s.categoria === "Serviços por KG";

export const ServicosPage = () => {
  const { clientes, isLoading: loadingClientes } = useClientes();
  const { servicos: servicosDB, isLoading: loadingServicos } = useServicos();
  const { addPedido } = usePedidos();
  const [selectedClienteId, setSelectedClienteId] = useState<string>("");
  const [quantidades, setQuantidades] = useState<Record<string, number>>({});
  const [searchTerm, setSearchTerm] = useState("");
  const [desconto, setDesconto] = useState<string>("");
  const [tipoDesconto, setTipoDesconto] = useState<"percentual" | "valor">("percentual");
  const [taxaEntrega, setTaxaEntrega] = useState<string>("");
  const [clienteComboOpen, setClienteComboOpen] = useState(false);
  /** Texto livre no campo de kg (evita confusão com type=number e vários pontos) */
  const [kgText, setKgText] = useState<Record<string, string>>({});
  const [balancaLeitura, setBalancaLeitura] = useState("");
  const [balancaGramas, setBalancaGramas] = useState(false);
  const [balancaServicoId, setBalancaServicoId] = useState("");

  const servicosKg = useMemo(
    () => servicosDB.filter((s) => isKgServico(s)),
    [servicosDB],
  );

  useEffect(() => {
    if (servicosKg.length === 0) return;
    if (!balancaServicoId || !servicosKg.some((s) => s.id === balancaServicoId)) {
      setBalancaServicoId(servicosKg[0].id);
    }
  }, [servicosKg, balancaServicoId]);

  const formatCurrency = (value: number) => {
    return value.toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
    });
  };

  // SECURITY: Sanitize text to prevent XSS in print output
  const sanitizeText = (text: string): string => {
    return DOMPurify.sanitize(text, { ALLOWED_TAGS: [] })
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;");
  };

  // Gerar relatório PDF de serviços
  const handleGerarRelatorio = () => {
    const printWindow = window.open("", "_blank");
    if (!printWindow) {
      toast.error("Não foi possível abrir a janela de impressão. Verifique o bloqueador de pop-ups.");
      return;
    }

    const tableRows = servicosDB.map((s, i) => `
      <tr>
        <td>${i + 1}</td>
        <td>${sanitizeText(s.nome)}</td>
        <td>${sanitizeText(s.categoria)}</td>
        <td class="preco">${formatCurrency(s.preco)}</td>
      </tr>
    `).join("");

    const html = `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Tabela de Preços - Lolana Lavanderia</title>
        <style>
          body { font-family: Arial, sans-serif; padding: 20px; }
          h1 { color: #1e40af; text-align: center; }
          .header { text-align: center; margin-bottom: 30px; }
          table { width: 100%; border-collapse: collapse; margin-top: 20px; }
          th { background-color: #1e3a5f; color: white; padding: 12px; text-align: left; }
          td { padding: 10px; border-bottom: 1px solid #ddd; }
          tr:nth-child(even) { background-color: #f9f9f9; }
          .categoria { font-weight: bold; background-color: #e0f2fe !important; }
          .preco { text-align: right; font-weight: bold; }
          .footer { margin-top: 30px; text-align: center; font-size: 12px; color: #666; }
          @media print { body { padding: 0; } }
        </style>
      </head>
      <body>
        <div class="header">
          <h1>🧺 Lolana Lavanderia</h1>
          <h2>Tabela de Preços</h2>
          <p>Data: ${new Date().toLocaleDateString("pt-BR")}</p>
        </div>
        <table>
          <thead>
            <tr>
              <th>#</th>
              <th>Serviço</th>
              <th>Categoria</th>
              <th class="preco">Preço</th>
            </tr>
          </thead>
          <tbody>
            ${tableRows}
          </tbody>
        </table>
        <div class="footer">
          <p><strong>Obs:</strong> Quando não atingir 1kg, será cobrado por valor unitário.</p>
          <p>Relatório gerado em ${new Date().toLocaleString("pt-BR")}</p>
        </div>
      </body>
      </html>
    `;

    printWindow.document.write(html);
    printWindow.document.close();
    printWindow.print();
  };

  const selectedCliente = clientes.find((c) => c.id === selectedClienteId);

  const getQuantidade = useCallback(
    (servico: ServicoDB): number => {
      if (!isKgServico(servico)) return quantidades[servico.id] || 0;
      if (!(servico.id in kgText)) return quantidades[servico.id] || 0;
      const raw = kgText[servico.id];
      if (!raw.trim()) return 0;
      const parsed = parseLeituraBalanca(raw);
      return parsed !== null ? parsed : quantidades[servico.id] || 0;
    },
    [quantidades, kgText],
  );

  const handleQuantidadeChange = (id: string, value: string) => {
    const num = parseInt(value, 10) || 0;
    setQuantidades((prev) => ({
      ...prev,
      [id]: Math.max(0, num),
    }));
  };

  const handleKgInputChange = (id: string, value: string) => {
    setKgText((prev) => ({ ...prev, [id]: value }));
  };

  const handleKgInputBlur = (id: string) => {
    const raw = kgText[id] ?? "";
    if (!raw.trim()) {
      setQuantidades((prev) => ({ ...prev, [id]: 0 }));
      setKgText((prev) => {
        const next = { ...prev };
        delete next[id];
        return next;
      });
      return;
    }
    const parsed = parseLeituraBalanca(raw);
    if (parsed === null) {
      toast.error(
        "Peso inválido. Ex.: 3,25 ou 3200 (= 3,2 kg). Só números: 1–2 caracteres = kg inteiros; 3+ = gramas. Evite vários pontos sem vírgula.",
      );
      setKgText((prev) => {
        const next = { ...prev };
        delete next[id];
        return next;
      });
      return;
    }
    setQuantidades((prev) => ({ ...prev, [id]: parsed }));
    setKgText((prev) => {
      const next = { ...prev };
      delete next[id];
      return next;
    });
  };

  const aplicarLeituraBalanca = () => {
    const sid =
      balancaServicoId && servicosKg.some((s) => s.id === balancaServicoId)
        ? balancaServicoId
        : servicosKg[0]?.id;
    if (!sid) {
      toast.error("Não há serviço por kg cadastrado.");
      return;
    }
    const kg = parseLeituraBalanca(balancaLeitura, { gramas: balancaGramas });
    if (kg === null) {
      toast.error(
        balancaGramas
          ? "Digite só números (cada unidade = 1 g, ex.: 3250 → 3,25 kg) ou use vírgula em kg."
          : "Valor inválido. Ex.: 3200 → 3,2 kg; 050 → 50 g; 12 → 12 kg; 3,25 ou 1.234,5.",
      );
      return;
    }
    setQuantidades((prev) => ({ ...prev, [sid]: kg }));
    setKgText((prev) => {
      const next = { ...prev };
      delete next[sid];
      return next;
    });
    setBalancaLeitura("");
    toast.success(`${formatKgBr(kg)} kg aplicado ao serviço selecionado.`);
  };

  const subtotal = useMemo(() => {
    return servicosDB.reduce((acc, servico) => {
      return acc + servico.preco * getQuantidade(servico);
    }, 0);
  }, [servicosDB, getQuantidade]);

  const descontoNum = parseFloat(desconto) || 0;
  const taxaEntregaNum = parseInt(taxaEntrega) || 0;
  
  const descontoTotal = tipoDesconto === "percentual" 
    ? (subtotal * descontoNum) / 100 
    : descontoNum;
  const total = Math.max(0, subtotal - descontoTotal + taxaEntregaNum);

  const categorias = useMemo(() => {
    return [...new Set(servicosDB.map((s) => s.categoria))];
  }, [servicosDB]);

  // Filtrar serviços pela busca (nome, categoria ou número)
  const servicosFiltrados = useMemo(() => {
    if (!searchTerm.trim()) return servicosDB;
    const term = searchTerm.toLowerCase().trim();
    
    const numeros = term.split(/[,\s]+/).map(n => parseInt(n.trim())).filter(n => !isNaN(n));
    
    if (numeros.length > 0) {
      return servicosDB.filter((s, index) => 
        numeros.includes(index + 1) ||
        s.nome.toLowerCase().includes(term) ||
        s.categoria.toLowerCase().includes(term)
      );
    }
    
    return servicosDB.filter(
      (s) =>
        s.nome.toLowerCase().includes(term) ||
        s.categoria.toLowerCase().includes(term)
    );
  }, [searchTerm, servicosDB]);

  // Agrupar serviços filtrados por categoria
  const categoriasFiltradas = useMemo(() => {
    return [...new Set(servicosFiltrados.map((s) => s.categoria))];
  }, [servicosFiltrados]);

  const getCategoryColor = (categoria: string) => {
    const colors: Record<string, string> = {
      "Serviços por KG": "bg-[hsl(210,100%,50%)]/10 text-[hsl(210,100%,50%)] border-[hsl(210,100%,50%)]/30",
      "Peças de Cama": "bg-[hsl(199,89%,48%)]/10 text-[hsl(199,89%,48%)] border-[hsl(199,89%,48%)]/30",
      "Camisas": "bg-[hsl(38,92%,50%)]/10 text-[hsl(38,92%,50%)] border-[hsl(38,92%,50%)]/30",
      "Vestido": "bg-[hsl(280,70%,50%)]/10 text-[hsl(280,70%,50%)] border-[hsl(280,70%,50%)]/30",
      "Valor Unitário": "bg-[hsl(142,76%,36%)]/10 text-[hsl(142,76%,36%)] border-[hsl(142,76%,36%)]/30",
    };
    return colors[categoria] || "bg-muted text-muted-foreground";
  };

  // Criar índice numérico para os serviços
  const servicoIndex = useMemo(() => {
    const index: Record<string, number> = {};
    servicosDB.forEach((s, i) => {
      index[s.id] = i + 1;
    });
    return index;
  }, [servicosDB]);

  const handleCriarPedido = () => {
    const cliente = clientes.find((c) => c.id === selectedClienteId);
    if (!cliente) {
      toast.error("Selecione um cliente!");
      return;
    }

    const itens: ItemPedido[] = servicosDB
      .filter((s) => getQuantidade(s) > 0)
      .map((s) => ({
        servico: { id: s.id, nome: s.nome, categoria: s.categoria, preco: s.preco },
        quantidade: getQuantidade(s),
      }));

    if (itens.length === 0) {
      toast.error("Selecione pelo menos um serviço!");
      return;
    }

    addPedido.mutate({ 
      cliente, 
      itens,
      descontoPercentual: tipoDesconto === "percentual" ? descontoNum : 0,
      descontoValor: tipoDesconto === "valor" ? descontoNum : 0,
      taxaEntrega: taxaEntregaNum
    });
    
    // Reset form
    setSelectedClienteId("");
    setQuantidades({});
    setKgText({});
    setDesconto("");
    setTipoDesconto("percentual");
    setTaxaEntrega("");
    setSearchTerm("");
  };

  const hasServicosSelected = servicosDB.some((s) => getQuantidade(s) > 0);

  // Adicionar serviço pela busca rápida
  const handleAddFromSearch = (servicoId: string) => {
    const servico = servicosDB.find((s) => s.id === servicoId);
    setQuantidades((prev) => ({
      ...prev,
      [servicoId]: (prev[servicoId] || 0) + 1,
    }));
    if (servico && isKgServico(servico)) {
      setKgText((prev) => {
        const next = { ...prev };
        delete next[servicoId];
        return next;
      });
    }
    toast.success("Serviço adicionado!");
  };

  if (loadingClientes || loadingServicos) {
    return (
      <MainLayout title="Serviços">
        <div className="flex items-center justify-center h-64">
          <Loader2 className="h-8 w-8 animate-spin text-primary" />
        </div>
      </MainLayout>
    );
  }

  return (
    <MainLayout title="Serviços">
      <div className="space-y-4 md:space-y-6">
        {/* Card de Seleção de Cliente */}
        <Card className="shadow-xl border-0 rounded-2xl overflow-hidden">
          <CardHeader className="bg-gradient-to-r from-[hsl(210,100%,50%)] to-[hsl(215,70%,35%)] text-white rounded-t-2xl py-4">
            <div className="flex items-center gap-3">
              <UserCheck className="h-5 w-5 md:h-6 md:w-6" />
              <CardTitle className="text-white text-lg md:text-xl">Selecionar Cliente</CardTitle>
            </div>
          </CardHeader>
          <CardContent className="py-4">
            <div className="flex flex-col md:flex-row md:items-end gap-4">
              <div className="flex-1 space-y-2">
                <Label>Cliente *</Label>
                <Popover open={clienteComboOpen} onOpenChange={setClienteComboOpen}>
                  <PopoverTrigger asChild>
                    <Button
                      variant="outline"
                      role="combobox"
                      aria-expanded={clienteComboOpen}
                      className="w-full justify-between rounded-xl h-10 font-normal"
                    >
                      {selectedCliente
                        ? `#${selectedCliente.numero} - ${selectedCliente.nome} | ${selectedCliente.telefone}`
                        : "Digite para buscar ou selecione um cliente..."}
                      <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-full p-0 rounded-xl" align="start">
                    <Command className="rounded-xl">
                      <CommandInput placeholder="Buscar cliente por nome, telefone ou número..." />
                      <CommandList>
                        <CommandEmpty>Nenhum cliente encontrado.</CommandEmpty>
                        <CommandGroup>
                          {clientes.map((cliente) => (
                            <CommandItem
                              key={cliente.id}
                              value={`${cliente.numero} ${cliente.nome} ${cliente.telefone}`}
                              onSelect={() => {
                                setSelectedClienteId(cliente.id);
                                setClienteComboOpen(false);
                              }}
                            >
                              <Check
                                className={cn(
                                  "mr-2 h-4 w-4",
                                  selectedClienteId === cliente.id ? "opacity-100" : "opacity-0"
                                )}
                              />
                              #{cliente.numero} - {cliente.nome} | {cliente.telefone}
                            </CommandItem>
                          ))}
                        </CommandGroup>
                      </CommandList>
                    </Command>
                  </PopoverContent>
                </Popover>
              </div>
              {clientes.length === 0 && (
                <p className="text-sm text-muted-foreground">
                  Cadastre clientes na aba "Clientes" primeiro
                </p>
              )}
            </div>
          </CardContent>
        </Card>

        {/* Card de Busca de Serviços */}
        <Card className="shadow-xl border-0 rounded-2xl overflow-hidden">
          <CardContent className="py-4">
            <div className="flex items-center gap-2 sm:gap-3">
              <Search className="h-4 w-4 sm:h-5 sm:w-5 text-muted-foreground flex-shrink-0" />
              <Input
                placeholder="Buscar por nome, categoria ou número (ex: 1,4,5)..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="flex-1 rounded-xl text-sm sm:text-base"
              />
            </div>
          </CardContent>
        </Card>

        {/* Card de Desconto e Taxa */}
        <Card className="shadow-xl border-0 rounded-2xl overflow-hidden">
          <CardHeader className="bg-[hsl(210,100%,97%)] py-3">
            <CardTitle className="text-[hsl(215,70%,25%)] text-base md:text-lg flex items-center gap-2">
              <Percent className="h-5 w-5" />
              Descontos e Taxas
            </CardTitle>
          </CardHeader>
          <CardContent className="py-4">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label className="flex items-center gap-2">
                  <Percent className="h-4 w-4" />
                  Desconto
                </Label>
                <div className="flex gap-2">
                  <Input
                    type="number"
                    min="0"
                    max={tipoDesconto === "percentual" ? 100 : undefined}
                    step="0.01"
                    value={desconto}
                    onChange={(e) => {
                      const value = e.target.value.replace(/[^0-9.]/g, "");
                      setDesconto(value);
                    }}
                    className="rounded-xl flex-1"
                  />
                  <Select value={tipoDesconto} onValueChange={(value: "percentual" | "valor") => setTipoDesconto(value)}>
                    <SelectTrigger className="w-24 rounded-xl">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent className="rounded-xl">
                      <SelectItem value="percentual">%</SelectItem>
                      <SelectItem value="valor">R$</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div className="space-y-2">
                <Label className="flex items-center gap-2">
                  <Truck className="h-4 w-4" />
                  Taxa de Entrega (R$)
                </Label>
                <Input
                  type="number"
                  min="0"
                  step="1"
                  value={taxaEntrega}
                  onChange={(e) => {
                    const value = e.target.value.replace(/[^0-9]/g, "");
                    setTaxaEntrega(value);
                  }}
                  className="rounded-xl"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {servicosKg.length > 0 && (
          <Card className="shadow-xl border-0 rounded-2xl overflow-hidden border-l-4 border-l-[hsl(199,89%,48%)]">
            <CardHeader className="bg-[hsl(199,89%,96%)] py-3">
              <CardTitle className="text-[hsl(215,70%,25%)] text-base md:text-lg flex items-center gap-2">
                <Scale className="h-5 w-5 shrink-0" />
                Peso na balança (picado)
              </CardTitle>
            </CardHeader>
            <CardContent className="py-4 space-y-4">
              <p className="text-sm text-muted-foreground">
                O total é preço por kg × peso. Você pode digitar o valor da balança aqui e aplicar, ou o peso em
                cada linha da tabela. Só números: três ou mais caracteres são tratados como gramas; um ou dois
                como quilos inteiros. Use vírgula para decimais em kg. A opção abaixo força leitura em gramas
                (divide por mil).
              </p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label>Aplicar em qual serviço por kg?</Label>
                  <Select value={balancaServicoId} onValueChange={setBalancaServicoId}>
                    <SelectTrigger className="rounded-xl">
                      <SelectValue placeholder="Selecione" />
                    </SelectTrigger>
                    <SelectContent className="rounded-xl">
                      {servicosKg.map((s) => (
                        <SelectItem key={s.id} value={s.id}>
                          #{servicoIndex[s.id]} — {s.nome} ({formatCurrency(s.preco)}/kg)
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label>Valor mostrado na balança</Label>
                  <Input
                    inputMode="decimal"
                    value={balancaLeitura}
                    onChange={(e) => setBalancaLeitura(e.target.value)}
                    className="rounded-xl"
                  />
                </div>
              </div>
              <div className="flex flex-col sm:flex-row sm:items-center gap-3 sm:gap-4">
                <label className="flex items-center gap-2 text-sm cursor-pointer select-none">
                  <Checkbox
                    checked={balancaGramas}
                    onCheckedChange={(v) => setBalancaGramas(v === true)}
                  />
                  Sempre gramas: divide o número inteiro por mil para obter kg
                </label>
                <Button
                  type="button"
                  onClick={aplicarLeituraBalanca}
                  variant="secondary"
                  className="rounded-xl sm:ml-auto w-full sm:w-auto"
                >
                  Aplicar peso ao serviço
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Tabela de Serviços */}
        <Card className="shadow-xl border-0 rounded-2xl overflow-hidden">
          <CardHeader className="bg-[hsl(210,100%,97%)] rounded-t-2xl">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
              <div className="flex items-center gap-3">
                <Package className="h-5 w-5 md:h-6 md:w-6 text-[hsl(210,100%,50%)]" />
                <CardTitle className="text-[hsl(215,70%,25%)] text-lg md:text-xl">Tabela de Serviços</CardTitle>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleGerarRelatorio}
                  className="rounded-xl gap-2 ml-2"
                >
                  <FileText className="h-4 w-4" />
                  <span className="hidden sm:inline">Gerar Relatório</span>
                </Button>
              </div>
              <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 sm:gap-4">
                <div className="text-left sm:text-right space-y-1">
                  <p className="text-sm text-muted-foreground">Subtotal: {formatCurrency(subtotal)}</p>
                  {descontoTotal > 0 && (
                    <p className="text-sm text-red-500">
                      Desconto{tipoDesconto === "percentual" ? ` (${desconto}%)` : ""}: -{formatCurrency(descontoTotal)}
                    </p>
                  )}
                  {taxaEntregaNum > 0 && (
                    <p className="text-sm text-muted-foreground">
                      Taxa: +{formatCurrency(taxaEntregaNum)}
                    </p>
                  )}
                  <p className="text-xl md:text-2xl font-bold text-[hsl(210,100%,50%)]">
                    Total: {formatCurrency(total)}
                  </p>
                </div>
                <Button 
                  onClick={handleCriarPedido} 
                  className="gap-2 rounded-xl bg-gradient-to-r from-[hsl(142,76%,36%)] to-[hsl(142,76%,30%)] hover:from-[hsl(142,76%,32%)] hover:to-[hsl(142,76%,26%)] w-full sm:w-auto"
                  size="lg"
                  disabled={!selectedClienteId || !hasServicosSelected || addPedido.isPending}
                >
                  <ShoppingCart className="h-5 w-5" />
                  Concluir Serviço
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            {/* Mobile Cards View */}
            <div className="block md:hidden divide-y">
              {servicosFiltrados.map((servico) => (
                <div 
                  key={servico.id} 
                  className={`p-4 space-y-3 ${getQuantidade(servico) > 0 ? "bg-[hsl(210,100%,95%)]" : ""}`}
                >
                  <div className="flex items-start justify-between gap-2">
                    <div className="space-y-1">
                      <div className="flex items-center gap-2">
                        <span className="text-xs font-mono text-muted-foreground">
                          #{servicoIndex[servico.id]}
                        </span>
                        <p className="font-medium">{servico.nome}</p>
                      </div>
                      <Badge
                        variant="outline"
                        className={`${getCategoryColor(servico.categoria)} rounded-lg text-xs`}
                      >
                        {servico.categoria}
                      </Badge>
                    </div>
                    <p className="font-mono font-semibold text-right">
                      {formatCurrency(servico.preco)}
                    </p>
                  </div>
                  <div className="flex items-center justify-between gap-4">
                    <div className="flex items-center gap-2 flex-wrap">
                      <Label className="text-sm">
                        {isKgServico(servico) ? "Kg:" : "Qtd:"}
                      </Label>
                      {isKgServico(servico) ? (
                        <Input
                          inputMode="decimal"
                          value={
                            servico.id in kgText ? kgText[servico.id] : ""
                          }
                          onChange={(e) =>
                            handleKgInputChange(servico.id, e.target.value)
                          }
                          onBlur={() => handleKgInputBlur(servico.id)}
                          className="w-24 text-center rounded-xl"
                        />
                      ) : (
                        <Input
                          type="number"
                          min="0"
                          step="1"
                          value={
                            quantidades[servico.id] && quantidades[servico.id] > 0
                              ? quantidades[servico.id]
                              : ""
                          }
                          onChange={(e) =>
                            handleQuantidadeChange(servico.id, e.target.value)
                          }
                          className="w-20 text-center rounded-xl"
                        />
                      )}
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleAddFromSearch(servico.id)}
                        className="rounded-xl"
                      >
                        {isKgServico(servico) ? "+1 kg" : "+1"}
                      </Button>
                    </div>
                    {getQuantidade(servico) > 0 && (
                      <p className="font-mono font-bold text-[hsl(210,100%,50%)]">
                        {formatCurrency(
                          servico.preco * getQuantidade(servico),
                        )}
                      </p>
                    )}
                  </div>
                </div>
              ))}
            </div>

            {/* Desktop Table View */}
            <div className="hidden md:block overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="bg-[hsl(215,70%,25%)]">
                    <TableHead className="w-16 text-white font-bold">#</TableHead>
                    <TableHead className="text-white font-bold">Serviço</TableHead>
                    <TableHead className="w-40 text-white font-bold">Categoria</TableHead>
                    <TableHead className="w-32 text-right text-white font-bold">Preço Unit.</TableHead>
                    <TableHead className="w-40 text-center text-white font-bold">Quantidade</TableHead>
                    <TableHead className="w-32 text-right text-white font-bold">Total</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {servicosFiltrados.map((servico) => (
                    <TableRow
                      key={servico.id}
                      className={`hover:bg-[hsl(210,100%,98%)] ${
                        getQuantidade(servico) > 0 ? "bg-[hsl(210,100%,95%)]" : ""
                      }`}
                    >
                      <TableCell className="font-mono text-muted-foreground">
                        #{servicoIndex[servico.id]}
                      </TableCell>
                      <TableCell className="font-medium">
                        {servico.nome}
                      </TableCell>
                      <TableCell>
                        <Badge
                          variant="outline"
                          className={`${getCategoryColor(servico.categoria)} rounded-lg`}
                        >
                          {servico.categoria}
                        </Badge>
                      </TableCell>
                      <TableCell className="text-right font-mono font-semibold">
                        {formatCurrency(servico.preco)}
                      </TableCell>
                      <TableCell className="text-center">
                        <div className="flex items-center justify-center gap-2 flex-wrap">
                          {isKgServico(servico) ? (
                            <Input
                              inputMode="decimal"
                              value={
                                servico.id in kgText ? kgText[servico.id] : ""
                              }
                              onChange={(e) =>
                                handleKgInputChange(servico.id, e.target.value)
                              }
                              onBlur={() => handleKgInputBlur(servico.id)}
                              className="w-24 text-center rounded-xl"
                            />
                          ) : (
                            <Input
                              type="number"
                              min="0"
                              step="1"
                              value={
                                quantidades[servico.id] &&
                                quantidades[servico.id] > 0
                                  ? quantidades[servico.id]
                                  : ""
                              }
                              onChange={(e) =>
                                handleQuantidadeChange(
                                  servico.id,
                                  e.target.value,
                                )
                              }
                              className="w-20 text-center rounded-xl"
                            />
                          )}
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => handleAddFromSearch(servico.id)}
                            className="rounded-xl shrink-0"
                          >
                            {isKgServico(servico) ? "+1 kg" : "+1"}
                          </Button>
                        </div>
                      </TableCell>
                      <TableCell className="text-right font-mono font-bold">
                        {getQuantidade(servico) > 0 ? (
                          <span className="text-[hsl(210,100%,50%)]">
                            {formatCurrency(
                              servico.preco * getQuantidade(servico),
                            )}
                          </span>
                        ) : (
                          <span className="text-muted-foreground">
                            {formatCurrency(0)}
                          </span>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
            <div className="p-4 bg-[hsl(210,100%,97%)] border-t">
              <p className="text-sm text-muted-foreground text-center">
                <strong>Obs:</strong> Quando não atingir 1kg, será cobrado por valor unitário. No peso por kg,
                três ou mais dígitos só numéricos contam como gramas; um ou dois como kg inteiros; vírgula para
                decimal. Veja o bloco &quot;Peso na balança&quot; acima.
              </p>
            </div>
          </CardContent>
        </Card>
      </div>
    </MainLayout>
  );
};
