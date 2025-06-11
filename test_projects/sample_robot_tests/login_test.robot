*** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           JSONLibrary

Suite Setup       Create API Session    base_url=${BASE_URL}
Suite Teardown    Delete All Users

Variables         ../resources/variables.robot

*** Variables ***
${BASE_URL}       https://api.exemplo.com
${CONTENT_TYPE}   application/json
${USERS_ENDPOINT}   /users

*** Test Cases ***

#------------------------------#
# Cenário 1: Listar Usuários   #
#------------------------------#
Listar Todos os Usuários
    [Tags]    users    GET
    ${resp}=    GET    ${USERS_ENDPOINT}
    Status Deve Ser    ${resp}    200
    ${lista}=    To JSON    ${resp.content}
    Length Should Be    ${lista}    0    # assume que inicialmente não há usuários

#------------------------------------------------#
# Cenário 2: Criar um novo usuário (POST /users)   #
#------------------------------------------------#
Criar Novo Usuário
    [Tags]    users    POST
    ${body}=    Create Dictionary    name=Maria Silva    email=maria.silva@example.com
    ${resp}=    POST    ${USERS_ENDPOINT}    json=${body}
    Status Deve Ser    ${resp}    201
    ${dados_criados}=    To JSON    ${resp.content}
    Should Contain Key    ${dados_criados}    id
    Should Be Equal    ${dados_criados.name}    Maria Silva
    # Armazenar o ID criado para uso posterior
    Set Suite Variable    ${USER_ID}    ${dados_criados.id}

#------------------------------------------------#
# Cenário 3: Obter detalhes de um usuário (GET)   #
#------------------------------------------------#
Obter Detalhes do Usuário Criado
    [Tags]    users    GET
    ${endpoint}=    Catenate    SEPARATOR=    ${USERS_ENDPOINT}    /    ${USER_ID}
    ${resp}=    GET    ${endpoint}
    Status Deve Ser    ${resp}    200
    ${dados}=    To JSON    ${resp.content}
    Should Be Equal    ${dados.id}    ${USER_ID}
    Should Be Equal    ${dados.email}    maria.silva@example.com

#------------------------------------------------#
# Cenário 4: Atualizar usuário existente (PUT)    #
#------------------------------------------------#
Atualizar Usuário Existente
    [Tags]    users    PUT
    ${endpoint}=    Catenate    SEPARATOR=    ${USERS_ENDPOINT}    /    ${USER_ID}
    ${novo_body}=    Create Dictionary    name=Maria S.    email=maria.s@example.com
    ${resp}=    PUT    ${endpoint}    json=${novo_body}
    Status Deve Ser    ${resp}    200
    ${dados_atualizados}=    To JSON    ${resp.content}
    Should Be Equal    ${dados_atualizados.name}    Maria S.
    Should Be Equal    ${dados_atualizados.email}    maria.s@example.com

#------------------------------------------------#
# Cenário 5: Deletar usuário (DELETE)             #
#------------------------------------------------#
Deletar Usuário
    [Tags]    users    DELETE
    ${endpoint}=    Catenate    SEPARATOR=    ${USERS_ENDPOINT}    /    ${USER_ID}
    ${resp}=    DELETE    ${endpoint}
    Status Deve Ser    ${resp}    204
    # Conferir que o usuário não existe mais
    ${resp2}=    GET    ${endpoint}
    Status Deve Ser    ${resp2}    404

#------------------------------------------------------#
# Cenário 6: Fluxo completo de CRUD de múltiplos usuários #
#------------------------------------------------------#
Fluxo Completo de Vários Usuários
    [Tags]    users    CRUD    fluxo
    # 1. Criar três usuários diferentes
    ${lista_usuarios}=    Create List
    : FOR    ${i}    IN RANGE    1    4
    \    ${body}=    Create Dictionary    name=Usuário${i}    email=usuario${i}@exemplo.com
    \    ${resp}=    POST    ${USERS_ENDPOINT}    json=${body}
    \    Status Deve Ser    ${resp}    201
    \    ${dados}=    To JSON    ${resp.content}
    \    Append To List    ${lista_usuarios}    ${dados.id}
    END
    Should Be True    ${lista_usuarios} != []

    # 2. Listar todos e verificar que há ao menos 3
    ${resp_list}=    GET    ${USERS_ENDPOINT}
    Status Deve Ser    ${resp_list}    200
    ${todos}=    To JSON    ${resp_list.content}
    Length Should Be Greater Than Or Equal To    ${todos}    3

    # 3. Atualizar o segundo usuário
    ${segundo_id}=    Get From List    ${lista_usuarios}    1
    ${endpoint_segundo}=    Catenate    SEPARATOR=    ${USERS_ENDPOINT}    /    ${segundo_id}
    ${body_update}=    Create Dictionary    name=Usuário2Atualizado    email=usuario2a@exemplo.com
    ${resp_update}=    PUT    ${endpoint_segundo}    json=${body_update}
    Status Deve Ser    ${resp_update}    200
    ${dados_up}=    To JSON    ${resp_update.content}
    Should Be Equal    ${dados_up.name}    Usuário2Atualizado

    # 4. Deletar o terceiro usuário
    ${terceiro_id}=    Get From List    ${lista_usuarios}    2
    ${endpoint_terceiro}=    Catenate    SEPARATOR=    ${USERS_ENDPOINT}    /    ${terceiro_id}
    ${resp_del3}=    DELETE    ${endpoint_terceiro}
    Status Deve Ser    ${resp_del3}    204

    # 5. Validar que só restaram 2 dos 3 criados
    ${resp_final}=    GET    ${USERS_ENDPOINT}
    Status Deve Ser    ${resp_final}    200
    ${lista_final}=    To JSON    ${resp_final.content}
    ${ids_restantes}=    Get Values From List    ${lista_final}    id
    Should Contain    ${ids_restantes}    ${lista_usuarios}[0]
    Should Contain    ${ids_restantes}    ${segundo_id}
    Should Not Contain    ${ids_restantes}    ${terceiro_id}

*** Keywords ***
Create API Session
    [Arguments]    ${base_url}
    Create Session    api_session    ${base_url}    headers=${NONE}

Status Deve Ser
    [Arguments]    ${response}    ${status_esperado}
    ${code}=    Get Response Status    ${response}
    Should Be Equal As Numbers    ${code}    ${status_esperado}

Get Response Status
    [Arguments]    ${response}
    ${status}=    Set Variable    ${response.status_code}
    [Return]    ${status}

Delete All Users
    [Documentation]    Limpa todos os usuários existentes para manter o ambiente “clean” para próximas execuções.
    ${resp}=    GET    ${USERS_ENDPOINT}
    ${todos}=    To JSON    ${resp.content}
    FOR    ${usuario}    IN    @{todos}
        ${endpoint}=    Catenate    SEPARATOR=    ${USERS_ENDPOINT}    /    ${usuario.id}
        DELETE    ${endpoint}
    END
