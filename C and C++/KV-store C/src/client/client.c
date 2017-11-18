#include <stdio.h>
#include<string.h>
#include <stdlib.h>
// protobuf-c headers
#include <protobuf-c/protobuf-c.h>
#include <protobuf-c-rpc/protobuf-c-rpc.h>
// Definitions for our protocol (under build/)
#include <protobuf/protocol.pb-c.h>
#include <pthread.h>

pthread_t tid;
char server_address[15];

static protobuf_c_boolean starts_with (const char *str, const char *prefix)
{
  return memcmp (str, prefix, strlen (prefix)) == 0;
}


static void kv_get_response (const Dkvs__Row *message,
                        void *closure_data)
 {

	printf("Client got get response\n");

   if (message == NULL)
     printf ("Error processing request.\n");
   else
     {
	   ProtobufCBinaryData key = message->key;
	   ProtobufCBinaryData value = message->value;
       printf ("key %s value %s\n",key.data,value.data);

     }

   * (protobuf_c_boolean *) closure_data = 1;
 }


static void kv_set_response (const Dkvs__Status *status,
                        void *closure_data)
 {

	printf("Client got set response\n");
   if (status == NULL)
     printf ("Error processing request.\n");
   else
     {
	   if (status->status == 1)
		   printf("Set Success\n");
	   else
		   printf("Set Failure\n");

     }

   * (protobuf_c_boolean *) closure_data = 1;
 }

static void build_and_send_get_Request(char* address_port)
{
	  ProtobufCService *service;
	  ProtobufC_RPC_Client *client;
	  ProtobufC_RPC_AddressType address_type=0;
	  const char *name = NULL;
	  unsigned i;

	  address_type = PROTOBUF_C_RPC_ADDRESS_TCP;
	 // signal (SIGPIPE, SIG_IGN);

	  service = protobuf_c_rpc_client_new (address_type, address_port, &dkvs__server__descriptor, NULL);
	  if (service == NULL)
	    {
		  printf ("error creating client");
		  exit(1);
	    }
	  client = (ProtobufC_RPC_Client *) service;
	  fprintf (stderr, "Connecting... ");
	  while (!protobuf_c_rpc_client_is_connected (client))
	    protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default());
	  fprintf (stderr, "done.\n");
	  protobuf_c_boolean is_done = 0;

	  Dkvs__RouterRequest myrequest= DKVS__ROUTER_REQUEST__INIT;
	   ProtobufCBinaryData bindata;
	   bindata.data = malloc(10);
	   strcpy(bindata.data,"Preethi\0");
	   bindata.len=strlen(bindata.data);
	   myrequest.key =  bindata;
		   dkvs__server__get(service, &myrequest,kv_get_response,&is_done);

		   while (!is_done)
	         protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default());

}


static void build_and_send_set_Request(char* address_port)
{
	  ProtobufCService *service;
	  ProtobufC_RPC_Client *client;
	  ProtobufC_RPC_AddressType address_type=0;
	  const char *name = NULL;
	  unsigned i;

	  address_type = PROTOBUF_C_RPC_ADDRESS_TCP;
	 // signal (SIGPIPE, SIG_IGN);

	  service = protobuf_c_rpc_client_new (address_type, address_port, &dkvs__server__descriptor, NULL);
	  if (service == NULL)
	    {
		  printf ("error creating client");
		  exit(1);
	    }
	  client = (ProtobufC_RPC_Client *) service;
	  fprintf (stderr, "Connecting... ");
	  while (!protobuf_c_rpc_client_is_connected (client))
	    protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default());
	  fprintf (stderr, "done.\n");
	  protobuf_c_boolean is_done = 0;

	    Dkvs__Row myrequest= DKVS__ROW__INIT;
	   ProtobufCBinaryData key;
	   ProtobufCBinaryData value;
	   key.data = malloc(10);
	   strcpy(key.data,"Preethi\0");
	   key.len=strlen(key.data);


	   value.data = malloc(14);

	   strcpy(value.data,"Ayyamperumal\0");
	   value.len=strlen(value.data);
	   myrequest.key   =  key;
	   myrequest.value =  value;


	   dkvs__server__set(service,&myrequest , kv_set_response,&is_done);

		   while (!is_done)
	         protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default());

}

static void router_address_response (const Dkvs__RouterResponse *result,
                        void *closure_data)
 {
	printf("Client got router response\n");

   if (result == NULL)
     printf ("Error processing request.\n");
   else
     {
	   strcpy(server_address,result->address);
     }
   * (protobuf_c_boolean *) closure_data = 1;
 }


int main(int argc,char** argv) {
  ProtobufCService *service;
  ProtobufC_RPC_Client *client;
  ProtobufC_RPC_AddressType address_type=0;
  const char *name = NULL;
  address_type = PROTOBUF_C_RPC_ADDRESS_TCP;
  name = argv[1];
  if (name == NULL)
  {
	  printf ("missing HOST:PORT ");
	  exit(1);
  }

  service = protobuf_c_rpc_client_new (address_type, name, &dkvs__router__descriptor, NULL);
  if (service == NULL)
    {
	  printf ("error creating client");
	  exit(1);
    }
  client = (ProtobufC_RPC_Client *) service;
  fprintf (stderr, "Connecting... ");
  while (!protobuf_c_rpc_client_is_connected (client))
    protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default ());
  fprintf (stderr, "done.\n");
  Dkvs__RouterRequest myrequest= DKVS__ROUTER_REQUEST__INIT;
  myrequest.key_length = 1;
  uint8_t temp = 10;
  ProtobufCBinaryData bindata;
  bindata.data = malloc(10);
  strcpy(bindata.data,"Preethi");
  bindata.len=strlen(bindata.data);
  myrequest.key =  bindata;
  protobuf_c_boolean is_done = 0;
  dkvs__router__get_server(service,
								 &myrequest,
								 router_address_response,
								 &is_done);

  while (!is_done)
	protobuf_c_rpc_dispatch_run (protobuf_c_rpc_dispatch_default ());

  printf ("server address %s\n",server_address);
  build_and_send_set_Request(server_address);
  build_and_send_get_Request(server_address);

  return 0;
}
