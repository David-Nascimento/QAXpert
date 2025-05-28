import io.restassured.RestAssured;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.equalTo;

public class LoginApiTest {
    @Test
    public void shouldReturnSuccessForValidLogin() {
        given().contentType("application/json")
               .body("{\"user\":\"admin\",\"pass\":\"123\"}")
        .when()
               .post("https://example.com/api/login")
        .then()
               .statusCode(200)
               .body("message", equalTo("success"));
    }
}