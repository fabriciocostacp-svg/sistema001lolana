import { Servico } from "@/types";

export const servicosFixos: Servico[] = [
  // Serviços por KG
  { id: "kg-1", nome: "Por Kg", categoria: "Serviços por KG", preco: 26.0 },
  {
    id: "kg-2",
    nome: "Kg lavada e passada",
    categoria: "Serviços por KG",
    preco: 22.0,
  },
  {
    id: "kg-3",
    nome: "Kg lavar ou passar",
    categoria: "Serviços por KG",
    preco: 22.0,
  },

  // Peças de Cama
  {
    id: "cama-1",
    nome: "Edredom de solteiro",
    categoria: "Peças de Cama",
    preco: 30.0,
  },
  {
    id: "cama-2",
    nome: "Edredom de casal",
    categoria: "Peças de Cama",
    preco: 42.0,
  },
  { id: "cama-3", nome: "Coberdrom", categoria: "Peças de Cama", preco: 50.0 },

  // Camisas
  {
    id: "camisa-1",
    nome: "Camisa manga longa (lavar e passar)",
    categoria: "Camisas",
    preco: 17.0,
  },
  {
    id: "camisa-2",
    nome: "Camisa manga longa (passar)",
    categoria: "Camisas",
    preco: 15.0,
  },
  {
    id: "camisa-3",
    nome: "Camisa manga curta (lavar e passar)",
    categoria: "Camisas",
    preco: 15.0,
  },
  {
    id: "camisa-4",
    nome: "Camisa manga curta (passar)",
    categoria: "Camisas",
    preco: 12.0,
  },

  // Vestido
  {
    id: "vestido-1",
    nome: "Vestido de festa (a partir de)",
    categoria: "Vestido",
    preco: 40.0,
  },

  // Valor Unitário
  { id: "unitario-1", nome: "Calça", categoria: "Valor Unitário", preco: 10.0 },
  {
    id: "unitario-2",
    nome: "Camiseta",
    categoria: "Valor Unitário",
    preco: 8.0,
  },
  { id: "unitario-3", nome: "Short", categoria: "Valor Unitário", preco: 6.0 },
  {
    id: "unitario-4",
    nome: "Paletó",
    categoria: "Valor Unitário",
    preco: 30.0,
  },
  {
    id: "unitario-5",
    nome: "Terno completo",
    categoria: "Valor Unitário",
    preco: 70.0,
  },
];
