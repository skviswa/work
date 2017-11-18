#include <stdio.h>
#include <protobuf-c/protobuf-c.h>
#include <protobuf-c-rpc/protobuf-c-rpc.h>
#include <protobuf/protocol.pb-c.h>
#include "uthash.h"
#include <string.h>


struct mykv {
    char key[20];             /* key (string is WITHIN the structure) */
    char value[20];
    UT_hash_handle hh;         /* makes this structure hashable */
};
struct mykv *s, *tmp, *kvstore = NULL;



static void key__set(Dkvs__Server_Service *service,const Dkvs__Row *input,Dkvs__Status_Closure closure,void *closure_data)
{

	printf("Server got set Request\n");
	(void) service;
	if (input == NULL)
		closure (NULL, closure_data);
	else
	{
		struct mykv * newentry= (struct mykv*)malloc(sizeof(struct mykv));
		strncpy(newentry->key, input->key.data, input->key.len);
		strncpy(newentry->value, input->value.data, input->value.len);
		//printf("Set Key Input %s Value Input %s input->key.len %lu  input->value.len %lu \n",newentry->key,newentry->value, input->key.len,input->value.len);

		HASH_ADD_STR( kvstore, key, newentry );
		Dkvs__Status result = DKVS__STATUS__INIT;
		result.status=1;
		closure (&result, closure_data);
	}
}
static void key__get(Dkvs__Server_Service *service,const Dkvs__RouterRequest *input,Dkvs__Row_Closure closure,void *closure_data)
{
	printf("Server got get Request\n");
	Dkvs__Row result = DKVS__ROW__INIT;

	(void) service;
	if (input == NULL)
	{
		printf("get Request Null");
		closure (NULL, closure_data);
	}
	else
	{
		printf("get Request Valid");
		ProtobufCBinaryData value;
		ProtobufCBinaryData key;
		struct mykv * kvresult = (struct mykv*)malloc(sizeof(struct mykv));
		if (kvresult)
		{
			HASH_FIND_STR( kvstore, input->key.data, kvresult);

			key.len = strlen(kvresult->key)+1;
			key.data = malloc(key.len);
			strncpy(key.data,kvresult->key,key.len);
			value.len= strlen(kvresult->value)+1;
			value.data = malloc(value.len);
			strncpy(value.data,kvresult->value,value.len);

		}

		/*strncpy(value.data,"Ayyamperumal",12);
		strncpy(key.data,"Preethi",7);
		key.len = 7;
		value.len = 12;*/
		result.key=key;
		result.value=value;
		closure (&result, closure_data);
	}
}


static Dkvs__Server_Service dkvs_serv_service =
		DKVS__SERVER__INIT(key__);

int main(int argc, char**argv) {

	ProtobufC_RPC_Server *server;
	ProtobufC_RPC_AddressType address_type=0;
	address_type = PROTOBUF_C_RPC_ADDRESS_TCP;
	const char *name = NULL;
	name = argv[1];
	server = protobuf_c_rpc_server_new (address_type, name, (ProtobufCService *) &dkvs_serv_service, NULL);
	for (;;)
		protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default ());
	return 0;
}


