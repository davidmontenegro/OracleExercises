package exportFiles;
import java.sql.*;
import java.time.LocalTime;
import java.io.File;
import java.io.PrintWriter;
import java.io.FileNotFoundException;

public class exportCSVFile {
    public static void main(String[] args) throws Exception {
        String serverName = "server.name";
        String portNumber = "portNumber";
        String sid = "QLD";
        String url = "jdbc:oracle:thin:@" + serverName + ":" + portNumber + "/" + sid;
        String username = "userName";
        String password = "password";
        String outputPath = "C:\\Users\\675105\\Desktop\\tmp\\";

        int location = 197;
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");

            Connection connection = DriverManager.getConnection(url, username,password);
            if(connection != null)
            {
              System.out.println("Connection established");
            }

            LocalTime startTime = LocalTime.now();
            System.out.println("Start time: " + startTime);

            String query = "SELECT /*+ INDEX (item_loc_soh index_soh_loc PARALLEL(8)) */ item, dept, unit_cost, stock_on_hand, ROUND(stock_on_hand*unit_cost, 2) AS stock_value FROM item_loc_soh WHERE loc = " + location;
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(query);


            String outputFile = outputPath + location + ".csv";
            resultToCsv(resultSet, outputFile);

            connection.close();
            LocalTime endTime = LocalTime.now();
            System.out.println("End time: " + endTime);
        } catch (Exception e) {
              e.printStackTrace();
            }
    }

    public static void resultToCsv(ResultSet rs, String outputFile) throws SQLException, FileNotFoundException {

        PrintWriter csvWriter = new PrintWriter(new File(outputFile));
        ResultSetMetaData meta = rs.getMetaData();
        int numberOfColumns = meta.getColumnCount();
        String dataHeaders = "\"" + meta.getColumnName(1) + "\"";
        for (int i = 2; i < numberOfColumns + 1; i++) {
          dataHeaders += ",\"" + meta.getColumnName(i).replaceAll("\"", "\\\"") + "\"";
        }
        csvWriter.println(dataHeaders);
        while (rs.next()) {
          String row = "\"" + rs.getString(1).trim().replaceAll("\"", "\\\"") + "\"";
          for (int i = 2; i < numberOfColumns + 1; i++) {
            row += ",\"" + rs.getString(i).trim().replaceAll("\"", "\\\"") + "\"";
          }
          csvWriter.println(row);
        }
        csvWriter.close();
      }
}
