import Test.Hspec

import LE1.Exercicio2
import LE1.Exercicio3
import LE1.Exercicio4

import System.IO (readFile)
import System.Directory (removeFile)
import System.IO.Temp (writeSystemTempFile)
import Data.Decimal (Decimal)

criaClientes :: Int -> Clientes -> Clientes
criaClientes x xs
  | x <= 0    = xs
  | otherwise = criaClientes (x - 1) (clientePadrao:xs)

main :: IO ()
main = hspec $ do
  describe "testa o TAD Conjunto de Inteiros" $ do
    let vazio' = []
    let xs     = [1,2,3,4]

    it "deve criar um conjunto vazio" $
      criaConjunto `shouldBe` vazio'

    it "deve inserir um elemento ao onjunto" $
      (elem 5) (insereItem 5 xs) `shouldBe` True

    it "deve remover um elemento do conjunto" $
      (elem 4) (removeItem 4 xs) `shouldBe` False

    describe "testa se um elemento pertence ou não a um conjunto" $ do
      it "deve retorna True se pertence" $
        pertence 4 xs `shouldBe` True

      it "deve retornar False se não pertence" $
        pertence 5 xs `shouldBe` False

    it "deve retornar o menor valor de um conjunto" $
      LE1.Exercicio2.min xs `shouldBe` 1

    describe "testa a união de dois conjuntos" $ do
      let ys    = [4,5,6,1]
      let unido = [1,2,3,4,5,6]

      it "deve retornar o sejunto conjunto caso o primeiro seja vazio" $
        uniao vazio' ys `shouldBe` ys

      it "deve unir corretamente os dois conjuntos" $
        uniao xs ys `shouldBe` unido

    describe "testa se um conjunto é igual a outro" $ do
      let ys = [1,2,3,4]
      let zs = [4,5,6]

      it "deve retornar True se os conjuntos são iguais" $
        igual xs ys `shouldBe` True

      it "deve retornar False se os conjuntos diferem-se" $
        igual xs zs `shouldBe `False

    describe "testa se um conjunto é vazio" $ do
      it "deve retornar True se um conjunto é vazio" $
        vazio vazio' `shouldBe` True

      it "deve retornar False se o conjunto possui elementos" $
        vazio xs `shouldBe` False

  describe "testa o TAD Data" $ do
    describe "testa a impressão de datas" $ do
      it "deve retornar Nothing se a data for inválida" $
        imprimeData (42, 13, 9999) `shouldBe` Nothing

      it "deve retornar uma data formatada" $
        imprimeData (27, 7, 2001) `shouldBe` Just "27/7/2001"

    describe "testa a conversão de string para data" $ do
      it "deve retornar a data correta a parit de uma string" $ do
        converteData "27/7/2001" (dataPadrao) `shouldBe` Just (Data 27 7 2001)
        converteData "12/12/2001" (dataPadrao) `shouldBe` Just (Data 12 12 2001)
        
      it "deve retornar Nothing se fevereiro for inválido" $
        converteData "31/2/2000" (dataPadrao) `shouldBe` (Nothing :: Maybe Data)

      it "deve retornar Nothing se qualquer parêmetro for inválido" $ do
        converteData "0/2/2000" (dataPadrao) `shouldBe` (Nothing :: Maybe Data)            
        converteData "1/0/2021" (dataPadrao) `shouldBe` (Nothing :: Maybe Data)            
        converteData "12/4/999" (dataPadrao) `shouldBe` (Nothing :: Maybe Data)            
        converteData "0/0/999" (dataPadrao) `shouldBe` (Nothing :: Maybe Data)      

    describe "testa a soma de dias" $ do
      let data' = Data 27 7 2001
      
      it "deve retornar a mesma data caso o número de dias seja 0" $
        somaDias data' 0 `shouldBe` Just data'

      it "deve retornar Nothing se os dias forem negativos" $ do
        somaDias data' (-2) `shouldBe` (Nothing :: Maybe Data)
        somaDias data' (-10) `shouldBe` (Nothing :: Maybe Data)
        somaDias data' (-90) `shouldBe` (Nothing :: Maybe Data)        

      it "deve retornar uma data com um ano a mais" $
        let Just (Data _ _ ano') = somaDias data' 365
            in ano' `shouldSatisfy` (> 2001)

      it "deve retornar uma data com um mês a mais" $ do
        somaDias data' 5 `shouldBe` Just (Data 1 8 2001)
        somaDias data' 10 `shouldBe` Just (Data 6 8 2001)

      it "deve retornar uma data com 2 meses a mais" $
        somaDias data' 37 `shouldBe` Just (Data 2 9 2001)

      it "deve retornar uma data com virada de ano" $
        let data'' = Data 31 12 2021
            in somaDias data'' 2 `shouldBe` Just (Data 2 1 2022)

      it "deve retornar uma data após N dias" $
        somaDias data' 2 `shouldBe` Just (Data 29 7 2001)

  describe "testa TAD Clientes" $ do
    let clientesPeq    = "./src/LE1/clientes_small.csv"
    let numClientesPeq = 30 :: Int
    let numClientesMed = 340 :: Int
    let clientesMed    = "./src/LE1/clientes_medium.csv"
    let cod            = 423 :: Integer
    let n              = "Joao"
    let en             = "Av. Alberto"
    let tel            = "(22)12345-6789"
    let data_primeira  = "27/07/2001"
    let data_ultima    = "27/07/2012"
    let valor          = 123.67 :: Decimal
    let cliente        = clientePadrao

    describe "testa a criação de um TAD Cliente" $ do      
      it "deve criar um cliente quando os argumentos são válidos" $
        criaCliente (cod, n, en, tel, data_primeira, data_ultima, valor) `shouldBe` cliente

    describe "testa o carregamento de TADs Clientes a paritr de um arquivo" $ do
      it "deve retornar uma lista de IO clientes se o arquivo existir e for válido" $ do
        clPeq    <- carregaClientes clientesPeq
        numClPeq <- numClientes $ return clPeq
        clMed    <- carregaClientes clientesMed
        numClMed <- numClientes $ return clMed
        numClPeq `shouldBe` numClientesPeq
        numClMed `shouldBe` numClientesMed

      it "deve lançar uma exeção caso o arquivo não exista ou seja inválido" $ do
        carregaClientes "./package.yaml" `shouldReturn` []
        carregaClientes "./app" `shouldReturn` []

    describe "testa o salvamento de apenas um Cliente" $ do
      it "deve salvar corretamente um cliente e atualizar um arquivo existente" $ do
        conteudo <- readFile clientesPeq
        tmp_path <- writeSystemTempFile "clientes_tmp.csv" conteudo
        _ <- salvaCliente cliente tmp_path
        numClientes (carregaClientes tmp_path) `shouldReturn` 31
        removeFile tmp_path

      it "deve salvar corretamente um cliente e criar um novo arquivo" $ do
        let tmp_path = "./clientes_tmp.csv"
        _ <- salvaCliente cliente tmp_path
        numClientes (carregaClientes tmp_path) `shouldReturn` 1
        removeFile tmp_path

    describe "testa o salvamento de multiplos clientes" $ do
      let clientes = return $ criaClientes 12 []

      it "deve salvar corretamente vários clientes e atualizar um arquivo existente" $ do
        conteudo <- readFile clientesPeq
        tmp_path <- writeSystemTempFile "clientes_tmp.csv" conteudo
        _ <- salvaClientes clientes tmp_path
        numClientes (carregaClientes tmp_path) `shouldReturn` 42
        removeFile tmp_path

      it "deve salvar corretamente vários clientes e criar um novo arquivo" $ do
        let tmp_path = "./clientes_tmp.csv"
        _ <- salvaClientes clientes tmp_path
        numClientes (carregaClientes tmp_path) `shouldReturn` 12
        removeFile tmp_path      
      
