export interface CepRuaEntry {
  cep: string;
  rua: string;
  bairro?: string;
  localidade?: string;
  estado?: string;
}

const RAW_CEPS = `Logradouro	Bairro	CEP	Localidade	Estado
Avenida 2	Centro	13530-001	Itirapina	SP
Avenida 1	Centro	13530-003	Itirapina	SP
Avenida 3	Centro	13530-005	Itirapina	SP
Avenida 5	Centro	13530-007	Itirapina	SP
Avenida 7	Centro	13530-009	Itirapina	SP
Avenida 9	Centro	13530-011	Itirapina	SP
Avenida 9A	Centro	13530-013	Itirapina	SP
Avenida 11	Centro	13530-015	Itirapina	SP
Rua 7	Centro	13530-017	Itirapina	SP
Rua 7A	Centro	13530-019	Itirapina	SP
Rua 6	Centro	13530-021	Itirapina	SP
Rua 5	Centro	13530-023	Itirapina	SP
Rua 4	Centro	13530-025	Itirapina	SP
Rua 3	Centro	13530-027	Itirapina	SP
Rua 2	Centro	13530-029	Itirapina	SP
Rua 1	Centro	13530-031	Itirapina	SP
Avenida Vereador José Roberto Marino	Jardim Lemos	13530-040	Itirapina	SP
Rua 2	Jardim Lemos	13530-042	Itirapina	SP
Rua 3	Jardim Lemos	13530-044	Itirapina	SP
Rua 4	Jardim Lemos	13530-046	Itirapina	SP
Rua 5	Jardim Lemos	13530-048	Itirapina	SP
Rua 6	Jardim Lemos	13530-050	Itirapina	SP
Rua 7	Jardim Lemos	13530-052	Itirapina	SP
Rua José de Ponte	Jardim dos Eucaliptos	13530-110	Itirapina	SP
Rua Armélio Guariento	Jardim dos Eucaliptos	13530-112	Itirapina	SP
Rua Luiz Ferreira Salles	Jardim dos Eucaliptos	13530-114	Itirapina	SP
Rua Leopoldo Lucas	Jardim dos Eucaliptos	13530-116	Itirapina	SP
Avenida Padre José Aparecido Chio	Jardim dos Eucaliptos	13530-118	Itirapina	SP
Rua Gentil Firmino Correa	Jardim dos Eucaliptos	13530-120	Itirapina	SP
Rua 1	Jardim dos Indaiás	13530-130	Itirapina	SP
Rua 2	Jardim dos Indaiás	13530-132	Itirapina	SP
Rua 3	Jardim dos Indaiás	13530-134	Itirapina	SP
Rua 4	Jardim dos Indaiás	13530-136	Itirapina	SP
Avenida José Bacciotti	Jardim dos Indaiás	13530-138	Itirapina	SP
Rua 7 B	Vila Santa Cruz	13530-140	Itirapina	SP
Rua 7 C	Vila Santa Cruz	13530-142	Itirapina	SP
Rua 7 D	Vila Santa Cruz	13530-144	Itirapina	SP
Rua 8	Vila Santa Cruz	13530-146	Itirapina	SP
Avenida 23	Vila Santa Cruz	13530-148	Itirapina	SP
Avenida 21	Vila Santa Cruz	13530-150	Itirapina	SP
Avenida 19	Vila Santa Cruz	13530-152	Itirapina	SP
Avenida 17	Vila Santa Cruz	13530-154	Itirapina	SP
Avenida 15	Vila Santa Cruz	13530-156	Itirapina	SP
Avenida 13	Vila Santa Cruz	13530-158	Itirapina	SP
Avenida 11	Vila Santa Cruz	13530-160	Itirapina	SP
Avenida 9	Vila Santa Cruz	13530-162	Itirapina	SP
Rua 5	Vila Cianelli	13530-170	Itirapina	SP
Rua 6	Vila Cianelli	13530-172	Itirapina	SP
Rua 7	Vila Cianelli	13530-174	Itirapina	SP
Rua 8	Vila Cianelli	13530-176	Itirapina	SP
Rua 9	Vila Cianelli	13530-178	Itirapina	SP
Avenida Cianelli	Vila Cianelli	13530-180	Itirapina	SP
Rua 10	Vila Cianelli	13530-182	Itirapina	SP
Rua 11	Vila Cianelli	13530-184	Itirapina	SP
Rua 12	Vila Cianelli	13530-186	Itirapina	SP
Avenida 9	Vila Cianelli	13530-188	Itirapina	SP
Avenida 7	Vila Cianelli	13530-190	Itirapina	SP
Avenida 5	Vila Cianelli	13530-192	Itirapina	SP
Avenida 3	Vila Cianelli	13530-194	Itirapina	SP
Avenida 1	Vila Cianelli	13530-186	Itirapina	SP
Avenida 2	Vila Cianelli	13530-188	Itirapina	SP
Avenida 4	Vila Cianelli	13530-200	Itirapina	SP
Rua Coaracy	Parque das Garças	13530-240	Itirapina	SP
Rua Potira	Parque das Garças	13530-242	Itirapina	SP
Rua Caiapós	Parque das Garças	13530-244	Itirapina	SP
Rua Tupiniquins	Parque das Garças	13530-246	Itirapina	SP
Rua Cataguases	Parque das Garças	13530-248	Itirapina	SP
Rua Jaguaruçu	Parque das Garças	13530-250	Itirapina	SP
Avenida Marginal A	Parque das Garças	13530-252	Itirapina	SP
Avenida Otoniel Augusto Rodrigues	Jardim Nova Itirapina	13530-260	Itirapina	SP
Avenida Marginal A	Jardim Nova Itirapina	13530-262	Itirapina	SP
Rua Bororós	Jardim Nova Itirapina	13530-264	Itirapina	SP
Rua Tupiniquins	Jardim Nova Itirapina	13530-268	Itirapina	SP
Rua Jaguaruçu	Jardim Nova Itirapina	13530-268	Itirapina	SP
Rua Araribóia	Jardim Nova Itirapina	13530-270	Itirapina	SP
Rua Jurupari	Jardim Nova Itirapina	13530-272	Itirapina	SP
Rua Aimorés	Jardim Nova Itirapina	13530-274	Itirapina	SP
Avenida Perimetral	Jardim Nova Itirapina	13530-276	Itirapina	SP
Rua Oitibó	Jardim Nova Itirapina	13530-278	Itirapina	SP
Rua Caiapós	Jardim Nova Itirapina	13530-280	Itirapina	SP
Rua Ceci	Jardim Nova Itirapina	13530-282	Itirapina	SP
Rua Jaci	Jardim Nova Itirapina	13530-284	Itirapina	SP
Rua Cataguases	Jardim Nova Itirapina	13530-286	Itirapina	SP
Rua Carijós	Jardim Nova Itirapina	13530-288	Itirapina	SP
Rua Tupi	Jardim Nova Itirapina	13530-290	Itirapina	SP
Rua Tapajós	Jardim Nova Itirapina	13530-292	Itirapina	SP
Rua Baturete	Jardim Nova Itirapina	13530-294	Itirapina	SP
Rua Jurema	Jardim Nova Itirapina	13530-296	Itirapina	SP
Rua Iracema	Jardim Nova Itirapina	13530-298	Itirapina	SP
Avenida Perimetral	Jardim Progresso	13530-300	Itirapina	SP
Rua 3	Jardim Progresso	13530-302	Itirapina	SP
Rua 1	Jardim Progresso	13530-304	Itirapina	SP
Rua 2	Jardim Progresso	13530-306	Itirapina	SP
Rodovia Engenheiro Paulo Nilo Romano	Zona Industrial I	13530-350	Itirapina	SP
Estrada Municipal Doutor Fernando de Arruda Botelho	Vila Pinhal	13530-450	Itirapina	SP
Estrada Municipal Doutor Fernando de Arruda Botelho	Balneário Santo Antônio	13530-460	Itirapina	SP
Rua 6	Vila Fepasa	13531-000	Itirapina	SP
Rua C	Vila Fepasa	13531-002	Itirapina	SP
Rua A	Vila Fepasa	13531-004	Itirapina	SP
Rua B	Vila Fepasa	13531-006	Itirapina	SP
Rua 1	Vila Fepasa	13531-008	Itirapina	SP
Rua 1	Vila Garbi	13531-010	Itirapina	SP
Rua 2	Vila Garbi	13531-012	Itirapina	SP
Rua 3	Vila Garbi	13531-014	Itirapina	SP
Rua 4	Vila Garbi	13531-016	Itirapina	SP
Rua 5	Vila Garbi	13531-018	Itirapina	SP
Avenida 4	Vila Garbi	13531-020	Itirapina	SP
Avenida 6	Vila Garbi	13531-022	Itirapina	SP
Avenida 8	Vila Garbi	13531-024	Itirapina	SP
Avenida 10	Vila Garbi	13531-026	Itirapina	SP
Avenida 10	Vila Monte Alegre	13531-030	Itirapina	SP
Avenida 10A	Vila Monte Alegre	13531-032	Itirapina	SP
Avenida 10B	Vila Monte Alegre	13531-034	Itirapina	SP
Avenida 12	Vila Monte Alegre	13531-036	Itirapina	SP
Avenida 14	Vila Monte Alegre	13531-038	Itirapina	SP
Avenida José Geraldo Parise Bianchini	Vila Monte Alegre	13531-040	Itirapina	SP
Rua 5	Vila Monte Alegre	13531-042	Itirapina	SP
Rua 4	Vila Monte Alegre	13531-044	Itirapina	SP
Rua 3	Vila Monte Alegre	13531-046	Itirapina	SP
Avenida 1	Residencial Dallas	13531-080	Itirapina	SP
Avenida 2	Residencial Dallas	13531-082	Itirapina	SP
Avenida 3	Residencial Dallas	13531-084	Itirapina	SP
Rua 1	Residencial Dallas	13531-086	Itirapina	SP
Rua 2	Residencial Dallas	13531-088	Itirapina	SP
Rua 3	Residencial Dallas	13531-090	Itirapina	SP
Rua 4	Residencial Dallas	13531-092	Itirapina	SP
Rua 2	Jardim Europa	13531-100	Itirapina	SP
Rua 3	Jardim Europa	13531-102	Itirapina	SP
Rua 4	Jardim Europa	13531-104	Itirapina	SP
Rua 5	Jardim Europa	13531-106	Itirapina	SP
Rua 1	Jardim Europa	13531-108	Itirapina	SP
Rua 6	Jardim Europa	13531-110	Itirapina	SP
Avenida Governador Mário Covas	Distrito Industrial	13531-120	Itirapina	SP
Avenida 2	Distrito Industrial	13531-122	Itirapina	SP
Avenida 1	Distrito Industrial	13531-124	Itirapina	SP
Avenida 3	Distrito Industrial	13531-126	Itirapina	SP
Avenida 5	Distrito Industrial	13531-128	Itirapina	SP
Avenida 6	Distrito Industrial	13531-130	Itirapina	SP
Rua 1	Distrito Industrial	13531-132	Itirapina	SP
Rua 2	Distrito Industrial	13531-134	Itirapina	SP
Rua Euvira Gobbi	Jardim Gobbi II	13531-140	Itirapina	SP
Rua Amélia Andriolli Gobbi	Jardim Gobbi II	13531-142	Itirapina	SP
Rua Ercília Gobbi	Jardim Gobbi II	13531-144	Itirapina	SP
Rua Guido Gobbi	Jardim Gobbi II	13531-146	Itirapina	SP
Rua Humberto Gobbi	Jardim Gobbi II	13531-148	Itirapina	SP
Rua Dionysio Gobbi	Jardim Gobbi	13531-150	Itirapina	SP
Rua Rosângela Aparecida Grossi	Jardim Gobbi	13531-152	Itirapina	SP
Rua Jandira Grossi	Jardim Gobbi	13531-154	Itirapina	SP
Rua Antônio Grossi	Jardim Gobbi	13531-156	Itirapina	SP
Rua José Grossi	Jardim Gobbi	13531-158	Itirapina	SP
Rua Sebastião Grossi	Jardim Gobbi	13531-160	Itirapina	SP
Avenida Vereador Evaldo José Nalin	Jardim Gobbi	13531-162	Itirapina	SP
Rua 1	Jardim do Sol	13531-170	Itirapina	SP
Rua 2	Jardim do Sol	13531-172	Itirapina	SP
Rua 3	Jardim do Sol	13531-174	Itirapina	SP
Rua 4	Jardim do Sol	13531-176	Itirapina	SP
Rua 5	Jardim do Sol	13531-178	Itirapina	SP
Rua A	Jardim do Sol	13531-180	Itirapina	SP
Rua B	Jardim do Sol	13531-182	Itirapina	SP
Rua C	Jardim do Sol	13531-184	Itirapina	SP
Rua 1	Jardim América	13531-190	Itirapina	SP
Rua 12	Jardim América	13531-192	Itirapina	SP
Rua 13	Jardim América	13531-194	Itirapina	SP
Rua 14	Jardim América	13531-196	Itirapina	SP
Rua 15	Jardim América	13531-198	Itirapina	SP
Rua 2	Jardim América	13531-200	Itirapina	SP
Rua 3	Jardim América	13531-202	Itirapina	SP
Rua 4	Jardim América	13531-204	Itirapina	SP
Rua 5	Jardim América	13531-206	Itirapina	SP
Rua 6	Jardim América	13531-208	Itirapina	SP
Rua 7	Jardim América	13531-210	Itirapina	SP
Rua 8	Jardim América	13531-212	Itirapina	SP
Rua 9	Jardim América	13531-214	Itirapina	SP
Rua 10	Jardim América	13531-216	Itirapina	SP
Rua 11	Jardim América	13531-218	Itirapina	SP
Avenida Marginal	Planalto Serra Verde	13531-350	Itirapina	SP
Rua 2	Planalto Serra Verde	13531-352	Itirapina	SP
Rua 4	Planalto Serra Verde	13531-354	Itirapina	SP
Rua 6	Planalto Serra Verde	13531-356	Itirapina	SP
Rua 8	Planalto Serra Verde	13531-358	Itirapina	SP
Rua 10	Planalto Serra Verde	13531-360	Itirapina	SP
Rua 12	Planalto Serra Verde	13531-362	Itirapina	SP
Rua 14	Planalto Serra Verde	13531-364	Itirapina	SP
Rua 16	Planalto Serra Verde	13531-366	Itirapina	SP
Rua 18	Planalto Serra Verde	13531-368	Itirapina	SP
Rua 20	Planalto Serra Verde	13531-370	Itirapina	SP
Rua 22	Planalto Serra Verde	13531-372	Itirapina	SP
Rua 24	Planalto Serra Verde	13531-374	Itirapina	SP
Rua 9	Planalto Serra Verde	13531-376	Itirapina	SP
Rua 5	Planalto Serra Verde	13531-378	Itirapina	SP
Rua 7	Planalto Serra Verde	13531-380	Itirapina	SP
Rua 3	Planalto Serra Verde	13531-382	Itirapina	SP
Rua 1	Planalto Serra Verde	13531-384	Itirapina	SP
Área Rural	Área Rural de Itirapina	13532-899	Itirapina	SP
Rua Família Guimarães	Centro (Itaqueri da Serra)	13533-000	Itirapina	SP
Rua Família Feltrin	Centro (Itaqueri da Serra)	13533-002	Itirapina	SP
Avenida Família Ferreira	Centro (Itaqueri da Serra)	13533-004	Itirapina	SP
Avenida Família Baldissera	Centro (Itaqueri da Serra)	13533-006	Itirapina	SP
Avenida Família Leite	Centro (Itaqueri da Serra)	13533-008	Itirapina	SP
Avenida Família Simões	Centro (Itaqueri da Serra)	13533-010	Itirapina	SP
Área Rural	Área Rural de Itaqueri da Serra	13533-899	Itirapina	SP`;

export const CEPS_CIDADE: CepRuaEntry[] = RAW_CEPS.trim()
  .split("\n")
  .slice(1)
  .map((line) => line.trim())
  .filter(Boolean)
  .map((line) => {
    const cols = line.split(/\t+|\s{2,}/).map((c) => c.trim());
    if (cols.length < 5) return null;

    const [rua, bairro, cep, localidade, estado] = cols;
    return { rua, bairro, cep, localidade, estado } satisfies CepRuaEntry;
  })
  .filter((entry): entry is CepRuaEntry => entry !== null);
