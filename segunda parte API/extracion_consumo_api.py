import requests
import pandas as pd

""""El settings tiene todas las configuraciones necesarias para la extraccion y consumo del api
    la variable 'search_to_compare' es una tupla con n busquedas a comparar
    la variable 'quantity_per_search' es la cantidad de items a sacar por cada busqueda, el api esta limitada a 50
    la variable 'columns_to_extract' son las columnas seleccionadas para realizar un analisis de la oferta
    la variable 'columns_to_add' son otras variablea a considerar en el analisis, pero toca desnoarmalizar
    por ultimo estan las urls de los servicios a usar del api de Meli 
"""
SETTINGS = {
    'search_to_compare': ('apple watch', 'samsung watch', 'huawei watch GT'),
    'quantity_per_search':'50',
    'columns_to_extract':[
            'id',
            'title',
            'seller_id',
            'price',
            'base_price',
            'original_price',
            'currency_id',
            'initial_quantity',
            'available_quantity',
            'sold_quantity',
            'buying_mode',
            'condition',
            'accepts_mercadopago',
            'location',
            'status'
            ],
    'columns_to_add':('country','state','city'),
    'url_to_search':'https://api.mercadolibre.com/sites/MLA/search?q=@search&limit=@limit#json',
    'url_find_items':'https://api.mercadolibre.com/items?ids=@ids'
}


def get_json_request(url):
    """"Realizar peticiones get apartir de una url y retorna la resuesta en formato json"""
    resp = requests.get(url=url)
    return resp.json()

def get_all_items(recherches,url):
    """" Este metodo realiza trae todos los items de las busquedas configuradas en la variable
        (search_to_compare) segun la cantidad de items que este configurada en la variable 
        (quantity_per_search) en el settings"""
    search_items={}
    for i in recherches:
        url=url.replace('@search',i)
        json_data=get_json_request(url)
        search_items[i]=[item['id'] for item in json_data['results']]
    return search_items

def get_set_items_dict(list_ids,url):
    """"Este metodo hace la busqueda de todos los items de una busqueda especifica usando el 
        el servicio expuesto que trae de a 20 items para mejorar tiempo de respuesta. si son mas de 20 items,
        hace particiones de a 20 hasta terminar con todos los items"""
    max =len(list_ids)
    items = []
    for i in range(0,max,20):
        ids_temp = ','.join(list_ids[i:i+20 if i+19<=max else max])
        url_temp = url.replace('@ids',ids_temp) 
        json_data=get_json_request(url_temp)
        items+=json_data
    return items

def map_dict_to_df(items_list, columns_to_map, columns_add):
    """"este metodo recibe la lista de todos los items sacados del metodo anterior y extrae solo las variables de interes,
        desnormalizando el json y retorna un dataframe que contiene todos los items de todas las busquedas con los
        datos solicitados"""
    data ={column:[] for column in columns_to_map+columns_add if column != 'location'}
    for item in items_list:
        item=item['body']
        for column in columns_to_map:
            if column != 'location':
                data[column].append(item[column])
            else:
                location =item['location']
                for geo in columns_add:
                    data[geo].append(location[geo] if location and location[geo] else None)
    return pd.DataFrame(data)
                
def extract_data(items_id_by_search,url):
    """"En este metodo empieza la extracion despues de tener todos los items de cada busqueda, por ultimo a cada datafame de cada busqueda
        le agrega la columna search para identificar que items pertenecen a cada busqueda"""
    df_set=[]
    for search in items_id_by_search:
        items_list=get_set_items_dict(items_id_by_search[search],url)
        df =map_dict_to_df(items_list,columns_to_extract,list(columns_to_add))
        df['search']=search
        df_set.append(df)
    return pd.concat(df_set, ignore_index=True)


if __name__ == '__main__':
    """"En el main se traen las variables del settings y se configura para la ejecucion.
        Por ultimo escribe un archivo .csv separado por ',' en el lugar de ejecucion
    """
    recherches = SETTINGS['search_to_compare']
    url_find_items = SETTINGS['url_find_items']
    url_to_search=SETTINGS['url_to_search'].replace('@limit',SETTINGS['quantity_per_search'])
    columns_to_extract=SETTINGS['columns_to_extract']
    columns_to_add=SETTINGS['columns_to_add']

    items_id_by_search =get_all_items(recherches,url_to_search)
    df = extract_data(items_id_by_search,url_find_items)
    df.to_csv('data_set.csv',index=False)