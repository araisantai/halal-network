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
	ID         string `json:"id"`
	Perusahaan string `json:"perusahaan"`
	Nama       string `json:"nama"`
	Nib        string `json:"nib"`
	Produk     string `json:"produk"`
	Alamat     string `json:"alamat"`
	Status     string `json:"status"`
	AddedAt    uint64 `json:"addedAt"`
}

func (s *SmartContract) CreateSertifikatHalal(ctx contractapi.TransactionContextInterface, halalData string) (string, error) {

	if len(halalData) == 0 {
		return "", fmt.Errorf("Please pass the correct halal data")
	}

	var halal SertifikatHalal
	err := json.Unmarshal([]byte(halalData), &halal)
	if err != nil {
		return "", fmt.Errorf("Failed while unmarshling halal. %s", err.Error())
	}

	halalAsBytes, err := json.Marshal(halal)
	if err != nil {
		return "", fmt.Errorf("failed while marshling halal. %s", err.Error())
	}

	ctx.GetStub().SetEvent("CreateAsset", halalAsBytes)

	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(halal.ID, halalAsBytes)
}

// func (s *SmartContract) Bid(ctx contractapi.TransactionContextInterface, orderID string) (string, error) {
// 	//verify that submitting client has the role of courier
// 	// err := ctx.GetClientIdentity().AssertAttributeValue("role", "Courier")
// 	// if err != nil {
// 	// 	return "", fmt.Errorf("submitting client not authorized to create a bid, does not have courier role")
// 	// }
// 	// get courier bid from transient map
// 	transientMap, err := ctx.GetStub().GetTransient()
// 	if err != nil {
// 		return "", fmt.Errorf("error getting transient: %v", err)
// 	}
// 	BidJSON, ok := transientMap["bid"]
// 	if !ok {
// 		return "", fmt.Errorf("bid key not found in the transient map")
// 	}
// 	// get the implicit collection name using the courier's organization ID and verify that courier is targeting their peer to store the bid
// 	// collection, err := getClientImplicitCollectionNameAndVerifyClientOrg(ctx)
// 	// if err != nil {
// 	// 	return "", err
// 	// }
// 	// the transaction ID is used as a unique index for the bid
// 	bidTxID := ctx.GetStub().GetTxID()

// 	// create a composite key using the transaction ID
// 	bidKey, err := ctx.GetStub().CreateCompositeKey("bid", []string{orderID, bidTxID})
// 	if err != nil {
// 		return "", fmt.Errorf("failed to create composite key: %v", err)
// 	}
// 	// put the bid into the organization's implicit data collection

// 	// err = ctx.GetStub().PutPrivateData(collection, bidKey, BidJSON)
// 	err = ctx.GetStub().PutPrivateData("_implicit_org_Org3MSP", bidKey, []byte(BidJSON))
// 	if err != nil {
// 		return "", fmt.Errorf("failed to input bid price into collection: %v", err)
// 	}
// 	// return the trannsaction ID so couriers can identify their bid
// 	return bidTxID, nil
// }

// func (s *SmartContract) ABACTest(ctx contractapi.TransactionContextInterface, halalData string) (string, error) {

// 	mspId, err := cid.GetMSPID(ctx.GetStub())
// 	if err != nil {
// 		return "", fmt.Errorf("failed while getting identity. %s", err.Error())
// 	}
// 	if mspId != "Org2MSP" {
// 		return "", fmt.Errorf("You are not authorized to create SertifikatHalal Data")
// 	}

// 	if len(halalData) == 0 {
// 		return "", fmt.Errorf("Please pass the correct halal data")
// 	}

// 	var halal SertifikatHalal
// 	err = json.Unmarshal([]byte(halalData), &halal)
// 	if err != nil {
// 		return "", fmt.Errorf("Failed while unmarshling halal. %s", err.Error())
// 	}

// 	halalAsBytes, err := json.Marshal(halal)
// 	if err != nil {
// 		return "", fmt.Errorf("Failed while marshling halal. %s", err.Error())
// 	}

// 	ctx.GetStub().SetEvent("CreateAsset", halalAsBytes)

// 	return ctx.GetStub().GetTxID(), ctx.GetStub().PutState(halal.ID, halalAsBytes)
// }

// func (s *SmartContract) CreatePrivateDataImplicitForOrg1(ctx contractapi.TransactionContextInterface, halalData string) (string, error) {

// 	if len(halalData) == 0 {
// 		return "", fmt.Errorf("please pass the correct document data")
// 	}

// 	var halal SertifikatHalal
// 	err := json.Unmarshal([]byte(halalData), &halal)
// 	if err != nil {
// 		return "", fmt.Errorf("failed while un-marshalling document. %s", err.Error())
// 	}

// 	halalAsBytes, err := json.Marshal(halal)
// 	if err != nil {
// 		return "", fmt.Errorf("failed while marshalling halal. %s", err.Error())
// 	}

// 	return ctx.GetStub().GetTxID(), ctx.GetStub().PutPrivateData("_implicit_org_Org1MSP", halal.ID, halalAsBytes)
// }

func (s *SmartContract) UpdateSertifikatHalalStatus(ctx contractapi.TransactionContextInterface, halalID string, newStatus string) (string, error) {

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

	halal := new(SertifikatHalal)
	_ = json.Unmarshal(halalAsBytes, halal)

	halal.Status = newStatus

	halalAsBytes, err = json.Marshal(halal)
	if err != nil {
		return "", fmt.Errorf("Failed while marshling halal. %s", err.Error())
	}

	//  txId := ctx.GetStub().GetTxID()

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

// GetCarById
func (s *SmartContract) GetSertifikatHalalById(ctx contractapi.TransactionContextInterface, halalID string) (*SertifikatHalal, error) {
	if len(halalID) == 0 {
		return nil, fmt.Errorf("Please provide correct contract Id")
		// return shim.Error("Incorrect number of arguments. Expecting 1")
	}

	halalAsBytes, err := ctx.GetStub().GetState(halalID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if halalAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", halalID)
	}

	halal := new(SertifikatHalal)
	_ = json.Unmarshal(halalAsBytes, halal)

	return halal, nil

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

// func (s *SmartContract) GetDocumentUsingCarContract(ctx contractapi.TransactionContextInterface, documentID string) (string, error) {
// 	if len(documentID) == 0 {
// 		return "", fmt.Errorf("Please provide correct contract Id")
// 	}

// 	params := []string{"GetDocumentById", documentID}
// 	queryArgs := make([][]byte, len(params))
// 	for i, arg := range params {
// 		queryArgs[i] = []byte(arg)
// 	}

// 	response := ctx.GetStub().InvokeChaincode("document_cc", queryArgs, "mychannel")

// 	return string(response.Payload), nil

// }

// func (s *SmartContract) CreateDocumentUsingCarContract(ctx contractapi.TransactionContextInterface, functionName string, documentData string) (string, error) {
// 	if len(documentData) == 0 {
// 		return "", fmt.Errorf("Please provide correct document data")
// 	}

// 	params := []string{functionName, documentData}
// 	queryArgs := make([][]byte, len(params))
// 	for i, arg := range params {
// 		queryArgs[i] = []byte(arg)
// 	}

// 	response := ctx.GetStub().InvokeChaincode("document_cc", queryArgs, "mychannel")

// 	return string(response.Payload), nil

// }

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
