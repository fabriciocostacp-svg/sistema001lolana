import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardContent, CardHeader } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
  DialogClose,
} from "@/components/ui/dialog";
import {
  Lock,
  User,
  HelpCircle,
  Phone,
  Key,
  CloudRain,
  Thermometer,
} from "lucide-react";
import { toast } from "sonner";
import { apiRequestPasswordReset, apiResetPassword } from "@/lib/api";
import { loginSchema, resetPasswordRequestSchema } from "@/lib/validation";
import lolanaLogo from "@/assets/lolana.png";

interface WeatherState {
  temperature: number;
  rainChance: number;
  precipitation: number;
}

export const LoginPage = () => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  // Forgot password states
  const [forgotOpen, setForgotOpen] = useState(false);
  const [forgotStep, setForgotStep] = useState<
    "phone" | "token" | "newPassword"
  >("phone");
  const [forgotPhone, setForgotPhone] = useState("");
  const [resetToken, setResetToken] = useState("");
  const [newPassword, setNewPassword] = useState("");
  const [foundUserName, setFoundUserName] = useState("");
  const [foundUserUsuario, setFoundUserUsuario] = useState("");
  const [isForgotLoading, setIsForgotLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validate input
    const result = loginSchema.safeParse({
      usuario: username,
      senha: password,
    });
    if (!result.success) {
      toast.error(result.error.errors[0].message);
      return;
    }

    setIsLoading(true);

    const success = await login(username, password);
    if (success) {
      toast.success("Bem-vindo à Lolana Lavanderia!");
      navigate("/clientes");
    } else {
      toast.error("Usuário ou senha incorretos!");
    }
    setIsLoading(false);
  };

  const handleForgotPassword = async () => {
    // Validate phone
    const result = resetPasswordRequestSchema.safeParse({
      telefone: forgotPhone,
    });
    if (!result.success) {
      toast.error(result.error.errors[0].message);
      return;
    }

    setIsForgotLoading(true);

    try {
      const response = await apiRequestPasswordReset(forgotPhone);

      if (response.success) {
        setResetToken(response.resetToken);
        setFoundUserName(response.nome);
        setFoundUserUsuario(response.usuario);
        setForgotStep("token");
        toast.success("Token de redefinição gerado!");
      }
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Erro ao buscar usuário!";
      toast.error(message);
    }

    setIsForgotLoading(false);
  };

  const handleResetPassword = async () => {
    if (newPassword.length < 4) {
      toast.error("Senha deve ter pelo menos 4 caracteres");
      return;
    }

    setIsForgotLoading(true);

    try {
      const response = await apiResetPassword(resetToken, newPassword);

      if (response.success) {
        toast.success(
          "Senha alterada com sucesso! Faça login com a nova senha.",
        );
        setForgotOpen(false);
        resetForgotDialog();
      }
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Erro ao alterar senha!";
      toast.error(message);
    }

    setIsForgotLoading(false);
  };

  const [now, setNow] = useState(new Date());
  const [weather, setWeather] = useState<WeatherState | null>(null);
  const [weatherLoading, setWeatherLoading] = useState(true);

  useEffect(() => {
    const timer = setInterval(() => setNow(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    const fetchWeather = async () => {
      try {
        const url =
          "https://api.open-meteo.com/v1/forecast?latitude=-22.25&longitude=-47.82&current=temperature_2m,precipitation&daily=precipitation_probability_max&timezone=America%2FSao_Paulo&forecast_days=1";
        const response = await fetch(url);
        if (!response.ok) throw new Error("Falha ao consultar clima");

        const data = (await response.json()) as {
          current?: { temperature_2m?: number; precipitation?: number };
          daily?: { precipitation_probability_max?: number[] };
        };

        setWeather({
          temperature: Number(data.current?.temperature_2m ?? 0),
          precipitation: Number(data.current?.precipitation ?? 0),
          rainChance: Number(
            data.daily?.precipitation_probability_max?.[0] ?? 0,
          ),
        });
      } catch {
        setWeather(null);
      } finally {
        setWeatherLoading(false);
      }
    };

    void fetchWeather();
    const weatherTimer = setInterval(
      () => {
        void fetchWeather();
      },
      15 * 60 * 1000,
    );

    return () => clearInterval(weatherTimer);
  }, []);

  const resetForgotDialog = () => {
    setForgotStep("phone");
    setForgotPhone("");
    setResetToken("");
    setNewPassword("");
    setFoundUserName("");
    setFoundUserUsuario("");
  };

  return (
    <div className="min-h-screen grid lg:grid-cols-2 bg-[hsl(210,18%,93%)]">
      <section className="relative overflow-hidden bg-gradient-to-b from-[hsl(219,74%,18%)] via-[hsl(218,72%,17%)] to-[hsl(217,76%,22%)] text-white p-8 md:p-12 lg:p-16 flex flex-col justify-between">
        <div className="absolute -top-10 -left-10 w-56 h-56 rounded-full bg-white/10 blur-2xl" />
        <div className="absolute bottom-20 right-8 w-40 h-40 rounded-full bg-[hsl(210,100%,50%)]/20 blur-xl" />

        <div className="relative flex flex-col items-center lg:items-start gap-8 mt-2 lg:mt-10">
          <div className="relative">
            <div className="absolute inset-0 rounded-full bg-white/10 blur-sm scale-110" />
            <img
              src={lolanaLogo}
              alt="Lolana Lavanderia"
              className="relative w-28 h-28 md:w-36 md:h-36 object-contain rounded-2xl shadow-2xl"
            />
          </div>

          <div className="text-center lg:text-left select-none">
            <p className="text-6xl md:text-7xl font-semibold tracking-tight leading-none">
              {now.toLocaleTimeString("pt-BR", {
                hour: "2-digit",
                minute: "2-digit",
              })}
            </p>
            <p className="mt-2 text-2xl md:text-4xl font-light text-white/85 capitalize">
              {now.toLocaleDateString("pt-BR", {
                weekday: "long",
                day: "2-digit",
                month: "long",
              })}
            </p>
          </div>

          <div className="w-full max-w-sm rounded-2xl border border-white/20 bg-white/10 backdrop-blur p-4 md:p-5">
            <p className="text-sm uppercase tracking-[0.15em] text-white/70 mb-3">
              Itirapina - Clima de Hoje
            </p>
            {weatherLoading ? (
              <p className="text-white/80 text-sm">Carregando previsao...</p>
            ) : weather ? (
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-white">
                  <Thermometer className="h-4 w-4 text-cyan-200" />
                  <span>{weather.temperature.toFixed(1)} C</span>
                </div>
                <div className="flex items-center gap-2 text-white">
                  <CloudRain className="h-4 w-4 text-blue-200" />
                  <span>Chance de chuva: {weather.rainChance}%</span>
                </div>
                <p className="text-xs text-white/75">
                  Precipitacao atual: {weather.precipitation.toFixed(1)} mm
                </p>
              </div>
            ) : (
              <p className="text-white/80 text-sm">
                Nao foi possivel carregar o clima agora.
              </p>
            )}
          </div>
        </div>

        <p className="relative text-center lg:text-left text-xs tracking-[0.2em] text-white/45 uppercase">
          Lolana Lavanderia
        </p>
      </section>

      <section className="flex items-center justify-center p-4 md:p-8">
        <Card className="w-full max-w-xl border-0 bg-transparent shadow-none">
          <CardHeader className="text-left pb-2">
            <h1 className="text-3xl font-bold text-[hsl(215,70%,15%)]">
              Acesse sua conta
            </h1>
            <p className="text-muted-foreground text-sm">
              Entre com suas credenciais para continuar
            </p>
          </CardHeader>
          <CardContent className="px-0 pb-2">
            <form onSubmit={handleSubmit} className="space-y-5">
              <div className="space-y-2">
                <Label htmlFor="username" className="text-[hsl(215,70%,25%)]">
                  Usuário
                </Label>
                <div className="relative">
                  <User className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <Input
                    id="username"
                    placeholder="ex: admin"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    className="pl-10 h-12 rounded-xl border border-[hsl(214,30%,84%)] focus:border-[hsl(210,100%,50%)] transition-colors bg-white/80"
                    required
                    maxLength={100}
                  />
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="password" className="text-[hsl(215,70%,25%)]">
                  Senha
                </Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <Input
                    id="password"
                    type="password"
                    placeholder="Digite sua senha"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    className="pl-10 h-12 rounded-xl border border-[hsl(214,30%,84%)] focus:border-[hsl(210,100%,50%)] transition-colors bg-white/80"
                    required
                    maxLength={100}
                  />
                </div>
              </div>
              <Button
                type="submit"
                className="w-full h-12 rounded-xl text-lg font-semibold bg-gradient-to-r from-[hsl(221,71%,53%)] to-[hsl(219,68%,47%)] hover:from-[hsl(221,72%,48%)] hover:to-[hsl(219,69%,42%)] shadow-lg transition-all duration-300"
                disabled={isLoading}
              >
                {isLoading ? (
                  <span className="flex items-center gap-2">
                    <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
                    Entrando...
                  </span>
                ) : (
                  "Entrar"
                )}
              </Button>

              <p className="text-center text-xs text-muted-foreground pt-1">
                Protegido por criptografia de ponta a ponta.
              </p>
            </form>

            <div className="mt-3 text-right">
              <Button
                variant="link"
                onClick={() => {
                  resetForgotDialog();
                  setForgotOpen(true);
                }}
                className="text-[hsl(221,71%,53%)] hover:text-[hsl(221,72%,45%)] gap-1 px-0"
              >
                Esqueci minha senha
              </Button>
            </div>
          </CardContent>
        </Card>
      </section>

      {/* Forgot Password Dialog */}
      <Dialog
        open={forgotOpen}
        onOpenChange={(open) => {
          setForgotOpen(open);
          if (!open) resetForgotDialog();
        }}
      >
        <DialogContent className="rounded-2xl mx-4 max-w-[calc(100vw-2rem)] sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-[hsl(215,70%,25%)] flex items-center gap-2">
              <HelpCircle className="h-5 w-5" />
              Recuperar Senha
            </DialogTitle>
          </DialogHeader>

          {forgotStep === "phone" && (
            <div className="space-y-4 py-4">
              <p className="text-sm text-muted-foreground">
                Digite o número de telefone cadastrado para recuperar sua senha.
              </p>
              <div className="space-y-2">
                <Label htmlFor="forgotPhone">Telefone Cadastrado</Label>
                <div className="relative">
                  <Phone className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <Input
                    id="forgotPhone"
                    placeholder="(00) 00000-0000"
                    value={forgotPhone}
                    onChange={(e) => setForgotPhone(e.target.value)}
                    className="pl-10 rounded-xl"
                    maxLength={20}
                  />
                </div>
              </div>
              <DialogFooter className="flex-col sm:flex-row gap-2 pt-2">
                <DialogClose asChild>
                  <Button
                    variant="outline"
                    className="rounded-xl w-full sm:w-auto"
                  >
                    Cancelar
                  </Button>
                </DialogClose>
                <Button
                  onClick={handleForgotPassword}
                  className="rounded-xl bg-gradient-to-r from-[hsl(210,100%,50%)] to-[hsl(215,70%,35%)] w-full sm:w-auto"
                  disabled={isForgotLoading}
                >
                  {isForgotLoading ? "Buscando..." : "Buscar"}
                </Button>
              </DialogFooter>
            </div>
          )}

          {forgotStep === "token" && (
            <div className="space-y-4 py-4">
              <div className="p-4 bg-green-50 border border-green-200 rounded-xl">
                <p className="text-sm text-green-800 font-medium mb-2">
                  Usuário encontrado!
                </p>
                <div className="space-y-1 text-sm">
                  <p>
                    <strong>Nome:</strong> {foundUserName}
                  </p>
                  <p>
                    <strong>Usuário:</strong> {foundUserUsuario}
                  </p>
                </div>
              </div>

              <div className="p-4 bg-blue-50 border border-blue-200 rounded-xl">
                <p className="text-sm text-blue-800 font-medium mb-2 flex items-center gap-2">
                  <Key className="h-4 w-4" />
                  Token de Redefinição
                </p>
                <p className="text-xs text-blue-600 mb-2">
                  Em um sistema real, este token seria enviado por SMS. Por
                  agora, use-o diretamente:
                </p>
                <code className="block bg-white p-2 rounded text-sm font-mono break-all">
                  {resetToken}
                </code>
              </div>

              <div className="space-y-2">
                <Label htmlFor="newPassword">Nova Senha</Label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <Input
                    id="newPassword"
                    type="password"
                    placeholder="Digite a nova senha"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    className="pl-10 rounded-xl"
                    maxLength={100}
                  />
                </div>
                <p className="text-xs text-muted-foreground">
                  Mínimo 4 caracteres
                </p>
              </div>

              <DialogFooter className="flex-col sm:flex-row gap-2 pt-2">
                <Button
                  variant="outline"
                  onClick={() => setForgotStep("phone")}
                  className="rounded-xl w-full sm:w-auto"
                >
                  Voltar
                </Button>
                <Button
                  onClick={handleResetPassword}
                  className="rounded-xl bg-gradient-to-r from-[hsl(142,76%,36%)] to-[hsl(142,76%,30%)] w-full sm:w-auto"
                  disabled={isForgotLoading || newPassword.length < 4}
                >
                  {isForgotLoading ? "Alterando..." : "Alterar Senha"}
                </Button>
              </DialogFooter>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
};
