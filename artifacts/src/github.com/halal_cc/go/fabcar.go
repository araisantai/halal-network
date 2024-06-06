package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"github.com/hyperledger/fabric/common/flogging"
)

type SmartContract struct {
	contractapi.Contract
}

var logger = flogging.MustGetLogger("fabcar_cc")

type SertifikatHalal struct {
	ID         string                 `json:"id"`
	Perusahaan string                 `json:"perusahaan"`
	Nama       string                 `json:"nama"`
	Nib        string                 `json:"nib"`
	Produk     string                 `json:"produk"`
	Alamat     string                 `json:"alamat"`
	Status     string                 `json:"status"`
	Bpjhname   string                 `json:"bpjhname"`
	Lphname    string                 `json:"Lphname"`
	AddedAt    int64                  `json:"addedAt"`
	Data       map[string]interface{} `json:"data"`
}

func (s *SmartContract) CreateSertifikatHalal(ctx contractapi.TransactionContextInterface, halalData string) (string, error) {

	if len(halalData) == 0 {
		return "", fmt.Errorf("Please pass the correct halal data")
	}

	var halal SertifikatHalal
	halal.AddedAt = time.Now().Unix()
	err := json.Unmarshal([]byte(halalData), &halal)
	if err != nil {
		return "", fmt.Errorf("Failed while unmarshaling halal. %s", err.Error())
	}

	halalAsBytes, err := json.Marshal(halal)
	if err != nil {
		return "", fmt.Errorf("Failed while marshaling halal. %s", err.Error())
	}

	ctx.GetStub().SetEvent("CreateAsset", halalAsBytes)

	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(halal.ID, halalAsBytes)
}

func (s *SmartContract) UpdateSertifikatHalalStatus(ctx contractapi.TransactionContextInterface, halalID string, newStatus string, typeUser string, nameValue string) (string, error) {

	if len(halalID) == 0 {
		return "", fmt.Errorf("Please pass the correct halal id")
	}

	halalAsBytes, err := ctx.GetStub().GetState(halalID)
	if err != nil {
		return "", fmt.Errorf("Failed to get halal data. %s", err.Error())
	}

	if halalAsBytes == nil {
		return "", fmt.Errorf("%s does not exist", halalID)
	}

	var halal SertifikatHalal
	_ = json.Unmarshal(halalAsBytes, &halal)

	halal.Status = newStatus
	if typeUser == "bpjhname" {
		halal.Bpjhname = nameValue
	} else if typeUser == "lphname" {
		halal.Lphname = nameValue
	} else {
		return "", fmt.Errorf("Invalid nameType. Must be 'bpjhname' or 'lphname'")
	}

	halalAsBytes, err = json.Marshal(halal)
	if err != nil {
		return "", fmt.Errorf("Failed while marshaling halal. %s", err.Error())
	}

	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(halal.ID, halalAsBytes)
}

func (s *SmartContract) GetHistoryForAsset(ctx contractapi.TransactionContextInterface, halalID string) (string, error) {

	resultsIterator, err := ctx.GetStub().GetHistoryForKey(halalID)
	if err != nil {
		return "", fmt.Errorf(err.Error())
	}
	defer resultsIterator.Close()

	var buffer bytes.Buffer
	buffer.WriteString("[")

	bArrayMemberAlreadyWritten := false
	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return "", fmt.Errorf(err.Error())
		}
		if bArrayMemberAlreadyWritten == true {
			buffer.WriteString(",")
		}
		buffer.WriteString("{\"TxId\":")
		buffer.WriteString("\"")
		buffer.WriteString(response.TxId)
		buffer.WriteString("\"")

		buffer.WriteString(", \"Value\":")
		if response.IsDelete {
			buffer.WriteString("null")
		} else {
			buffer.WriteString(string(response.Value))
		}

		buffer.WriteString(", \"Timestamp\":")
		buffer.WriteString("\"")
		buffer.WriteString(time.Unix(response.Timestamp.Seconds, int64(response.Timestamp.Nanos)).String())
		buffer.WriteString("\"")

		buffer.WriteString(", \"IsDelete\":")
		buffer.WriteString("\"")
		buffer.WriteString(strconv.FormatBool(response.IsDelete))
		buffer.WriteString("\"")

		buffer.WriteString("}")
		bArrayMemberAlreadyWritten = true
	}
	buffer.WriteString("]")

	return string(buffer.Bytes()), nil
}

// GetHalalById
func (s *SmartContract) GetSertifikatHalalById(ctx contractapi.TransactionContextInterface, halalID string) (*SertifikatHalal, error) {
	if len(halalID) == 0 {
		return nil, fmt.Errorf("Please provide correct contract Id")
	}

	halalAsBytes, err := ctx.GetStub().GetState(halalID)
	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if halalAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", halalID)
	}

	var halal SertifikatHalal
	_ = json.Unmarshal(halalAsBytes, &halal)

	return &halal, nil
}

func (s *SmartContract) DeleteSertifikatHalalById(ctx contractapi.TransactionContextInterface, halalID string) (string, error) {
	if len(halalID) == 0 {
		return "", fmt.Errorf("Please provide correct contract Id")
	}

	return ctx.GetStub().GetTxID(), ctx.GetStub().DelState(halalID)
}

func (s *SmartContract) GetContractsForQuery(ctx contractapi.TransactionContextInterface, queryString string) ([]SertifikatHalal, error) {

	queryResults, err := s.getQueryResultForQueryString(ctx, queryString)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from ----world state. %s", err.Error())
	}

	return queryResults, nil

}

func (s *SmartContract) getQueryResultForQueryString(ctx contractapi.TransactionContextInterface, queryString string) ([]SertifikatHalal, error) {

	resultsIterator, err := ctx.GetStub().GetQueryResult(queryString)
	if err != nil {
		return nil, err
	}
	defer resultsIterator.Close()

	results := []SertifikatHalal{}

	for resultsIterator.HasNext() {
		response, err := resultsIterator.Next()
		if err != nil {
			return nil, err
		}

		newCar := new(SertifikatHalal)

		err = json.Unmarshal(response.Value, newCar)
		if err != nil {
			return nil, err
		}

		results = append(results, *newCar)
	}
	return results, nil
}

func main() {

	chaincode, err := contractapi.NewChaincode(new(SmartContract))
	if err != nil {
		fmt.Printf("Error create fabcar chaincode: %s", err.Error())
		return
	}
	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting chaincodes: %s", err.Error())
	}

}
